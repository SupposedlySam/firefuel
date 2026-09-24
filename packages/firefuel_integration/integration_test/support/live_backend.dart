import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' show Settings;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firefuel/firefuel.dart';
import 'package:firefuel_integration/firebase_options.dart';

import '../../../firefuel/test/utils/test_backend.dart';
import 'default_app.dart';

/// The dedicated `firefuel-integration` Firebase project. Nothing else lives
/// there: [fresh] deletes every document in it.
///
/// Credentials come from `--dart-define`s that tool/test_live_firestore.sh
/// passes, both minted for the run and valid for an hour:
/// - a Firebase custom token for the uid the rules admit
///   (`firefuel-integration-suite`), signed through the project's Admin SDK
///   service account; custom-token sign-in allows 45,000 logins a minute,
///   where password sign-in hit its quota after about 120 tests;
/// - an OAuth token for the deletes, which go through the REST API because
///   the client SDK cannot list subcollections.
class LiveBackend implements TestBackend {
  LiveBackend()
    : _customToken = const String.fromEnvironment('FIREFUEL_LIVE_CUSTOM_TOKEN'),
      _token = const String.fromEnvironment('FIREFUEL_LIVE_TOKEN') {
    if (_customToken.isEmpty || _token.isEmpty) {
      throw StateError(
        'Live runs need FIREFUEL_LIVE_CUSTOM_TOKEN and FIREFUEL_LIVE_TOKEN; '
        'run tool/test_live_firestore.sh',
      );
    }
  }

  final String _customToken;
  final String _token;
  var _apps = 0;

  static final FirebaseOptions _options =
      DefaultFirebaseOptions.currentPlatform;
  static final _root =
      'projects/${_options.projectId}/databases/(default)/documents';

  @override
  String get name => 'the live firefuel-integration project';

  @override
  bool get isEmulator => false;

  /// One project cannot give a second, isolated Firestore.
  @override
  bool get providesOther => false;

  @override
  Future<FirebaseFirestore> freshOther() {
    throw UnsupportedError('$name has no second Firestore');
  }

  @override
  Future<FirebaseFirestore> fresh() async {
    await _deleteEverything();

    await ensureDefaultApp(_options);
    // A new app per test, as in EmulatorBackend. Sharing one instance leaked
    // state between tests when checked on the emulator
    // (tool/test_real_firestore.sh --shared-instance): a write from one test
    // held up the next test's writes.
    final app = await Firebase.initializeApp(
      name: 'firefuel-test-${_apps++}',
      options: _options,
    );
    await FirebaseAuth.instanceFor(
      app: app,
    ).signInWithCustomToken(_customToken);

    return FirebaseFirestore.instanceFor(app: app)
      ..settings = const Settings(persistenceEnabled: false);
  }

  Future<void> _deleteEverything() async {
    final client = HttpClient();
    try {
      final names = <String>[];
      await _collectDocuments(client, _root, names);
      // Children were collected before their parents; delete in that order.
      for (var i = 0; i < names.length; i += 500) {
        final batch = names.sublist(i, (i + 500).clamp(0, names.length));
        await _call(client, 'POST', '$_root:batchWrite', {
          'writes': [
            for (final name in batch) {'delete': name},
          ],
        });
      }
    } finally {
      client.close();
    }
  }

  /// Every document under [parent], deepest first, including "missing"
  /// documents that exist only as parents of subcollections.
  Future<void> _collectDocuments(
    HttpClient client,
    String parent,
    List<String> into,
  ) async {
    final ids = await _call(client, 'POST', '$parent:listCollectionIds', {
      'pageSize': 1000,
    });
    for (final id in (ids['collectionIds'] as List<dynamic>? ?? const [])) {
      String? pageToken;
      do {
        final page = await _call(
          client,
          'GET',
          '$parent/$id?pageSize=300&showMissing=true&mask.fieldPaths=__name__'
              '${pageToken == null ? '' : '&pageToken=$pageToken'}',
        );
        for (final doc in (page['documents'] as List<dynamic>? ?? const [])) {
          final name = (doc as Map<String, dynamic>)['name'] as String;
          await _collectDocuments(client, name, into);
          into.add(name);
        }
        pageToken = page['nextPageToken'] as String?;
      } while (pageToken != null);
    }
  }

  Future<Map<String, dynamic>> _call(
    HttpClient client,
    String method,
    String path, [
    Map<String, Object?>? body,
  ]) async {
    final request = await client.openUrl(
      method,
      Uri.parse('https://firestore.googleapis.com/v1/$path'),
    );
    request.headers
      ..set('Authorization', 'Bearer $_token')
      ..contentType = ContentType.json;
    if (body != null) request.write(jsonEncode(body));
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('$method $path: ${response.statusCode} $text');
    }
    return text.isEmpty ? {} : jsonDecode(text) as Map<String, dynamic>;
  }
}
