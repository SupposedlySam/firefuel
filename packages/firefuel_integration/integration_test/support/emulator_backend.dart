import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' show Settings;
import 'package:firebase_core/firebase_core.dart';
import 'package:firefuel/firefuel.dart';

import '../../../firefuel/test/utils/test_backend.dart';
import 'default_app.dart';

/// The Firestore emulator started by `firebase emulators:exec` with the
/// repo-root firebase.emulator.json, whose rules are open (see
/// firestore.emulator.rules), so tests need no sign-in. Firebase Auth on
/// macOS needs a keychain entitlement tied to a signing team.
class EmulatorBackend implements TestBackend {
  static const host = '127.0.0.1';
  static const firestorePort = 8181;

  /// `demo-` project ids never reach a real Firebase project.
  static const project = 'demo-firefuel';
  static const otherProject = 'demo-firefuel-other';

  /// Reuse one Firestore per project instead of a new app per test, as
  /// LiveBackend must. Set with `--dart-define=FIREFUEL_SHARED_INSTANCE=true`
  /// to check against the emulator that sharing an instance leaks nothing
  /// between tests.
  static const _shared = bool.fromEnvironment('FIREFUEL_SHARED_INSTANCE');
  final _sharedInstances = <String, FirebaseFirestore>{};
  var _apps = 0;

  @override
  String get name => 'the Firestore emulator';

  @override
  bool get providesOther => true;

  @override
  bool get isEmulator => true;

  @override
  Future<FirebaseFirestore> fresh() => _empty(project);

  @override
  Future<FirebaseFirestore> freshOther() => _empty(otherProject);

  /// A Firestore on [projectId] with every document deleted.
  ///
  /// Each call uses a new Firebase app. The SDK caches documents per
  /// instance, even with persistence off, so an instance reused after a wipe
  /// can serve a new listener the previous test's documents from its cache.
  Future<FirebaseFirestore> _empty(String projectId) async {
    await _wipe(projectId);
    if (_shared) {
      if (_sharedInstances[projectId] case final instance?) return instance;
    }

    await ensureDefaultApp(_options(project));

    final app = await Firebase.initializeApp(
      name: 'firefuel-test-${_apps++}',
      options: _options(projectId),
    );

    final instance = FirebaseFirestore.instanceFor(app: app)
      ..settings = const Settings(persistenceEnabled: false)
      ..useFirestoreEmulator(host, firestorePort);
    if (_shared) _sharedInstances[projectId] = instance;
    return instance;
  }

  // Format-valid placeholders: the native SDK aborts on a malformed key, but
  // no request made with them leaves this machine.
  static FirebaseOptions _options(String projectId) => FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForFirestoreEmulatorOnly00',
    appId: '1:123456789012:ios:0123456789abcdef',
    messagingSenderId: '123456789012',
    projectId: projectId,
  );

  static Future<void> _wipe(String projectId) async {
    final client = HttpClient();
    try {
      final request = await client.deleteUrl(
        Uri.http(
          '$host:$firestorePort',
          '/emulator/v1/projects/$projectId/databases/(default)/documents',
        ),
      );
      final response = await request.close();
      await response.drain<void>();
      if (response.statusCode != 200) {
        throw HttpException(
          'Emulator wipe of $projectId answered ${response.statusCode}',
        );
      }
    } finally {
      client.close();
    }
  }
}
