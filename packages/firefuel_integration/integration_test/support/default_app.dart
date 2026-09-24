import 'package:firebase_core/firebase_core.dart';

/// Makes sure a default Firebase app exists; cloud_firestore's platform
/// layer reads it even when every call names another app.
///
/// On iOS the bundled GoogleService-Info.plist makes the native SDK create
/// the default app at launch, before Dart can see it, so creating it again
/// reports `duplicate-app`. Either way a default app then exists.
Future<void> ensureDefaultApp(FirebaseOptions options) async {
  if (Firebase.apps.isNotEmpty) return;
  try {
    await Firebase.initializeApp(options: options);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
}
