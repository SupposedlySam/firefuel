import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:firefuel/firefuel.dart';

/// Where the test suite gets Firestore from.
///
/// By default every call returns a fresh [FakeFirebaseFirestore], and
/// `flutter test` in this package runs against the fake. The integration
/// app in `packages/firefuel_integration` installs a [TestBackend] that
/// returns a real Firestore (the emulator, or a live project) with an
/// empty database, and then runs these same test files. A test that passes
/// on the fake but fails there means the fake and Firestore disagree.
abstract class TestBackend {
  /// A Firestore holding no documents.
  Future<FirebaseFirestore> fresh();

  /// Whether [freshOther] is available. A single live project cannot give
  /// a second, isolated Firestore.
  bool get providesOther;

  /// A second empty Firestore, isolated from [fresh]'s. Only called when
  /// [providesOther] is true.
  Future<FirebaseFirestore> freshOther();

  /// A short name for skip messages, e.g. `emulator`.
  String get name;

  /// Whether this is the Firestore emulator rather than a live project.
  bool get isEmulator;
}

TestBackend? _installed;

/// Makes every [testFirestore] call use [backend]. Called by the
/// integration app before it runs the test files.
void installTestBackend(TestBackend backend) => _installed = backend;

/// Whether the suite is running against a real Firestore.
bool get onRealFirestore => _installed != null;

/// A Firestore with no documents, fake unless a backend is installed.
Future<FirebaseFirestore> testFirestore() async {
  return await _installed?.fresh() ?? FakeFirebaseFirestore();
}

/// A second Firestore isolated from [testFirestore]'s.
///
/// Only call it from tests declared with `skip: skipWithoutOtherFirestore`.
Future<FirebaseFirestore> otherTestFirestore() async {
  final backend = _installed;
  if (backend == null) return FakeFirebaseFirestore();

  if (!backend.providesOther) {
    throw StateError('${backend.name} has no second Firestore; skip the test');
  }
  return await backend.freshOther();
}

/// For `skip:` on tests that need [otherTestFirestore].
String? get skipWithoutOtherFirestore {
  final backend = _installed;
  if (backend == null || backend.providesOther) return null;
  return 'needs a second, isolated Firestore, which ${backend.name} lacks';
}

/// For `skip:` on tests of behaviour the Firestore emulator lacks but live
/// Firestore is expected to have. The live run still checks them.
String? emulatorGap(String reason) {
  return (_installed?.isEmulator ?? false) ? 'emulator gap: $reason' : null;
}

/// For `skip:` on tests that exercise fake_cloud_firestore itself rather
/// than firefuel, so have nothing to verify against a real backend.
String? fakeOnly(String reason) {
  return onRealFirestore ? 'fake_cloud_firestore only: $reason' : null;
}
