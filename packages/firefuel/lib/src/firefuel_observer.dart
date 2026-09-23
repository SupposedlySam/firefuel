import 'dart:developer' as developer;

import 'package:firefuel/firefuel.dart';

/// Hears about failures firefuel handles, so an app can log or report them
/// in one place.
///
/// Set one with `Firefuel.initialize(firestore, observer: MyObserver())`.
/// Extend it and override what you need; every method has a default.
///
/// ```dart
/// class CrashlyticsObserver extends FirefuelObserver {
///   const CrashlyticsObserver();
///
///   @override
///   void onFailure(Failure failure) {
///     FirebaseCrashlytics.instance.recordError(
///       failure.error,
///       failure.stackTrace,
///     );
///   }
/// }
/// ```
class FirefuelObserver {
  const FirefuelObserver();

  /// Called with every [Failure] a repository (or any `guard` /
  /// `guardStream` call) turns into a Left, and with every write that fails
  /// after it was acknowledged locally (see [WriteAcknowledgement.local]).
  ///
  /// The default writes the failure to `dart:developer`'s log, which shows
  /// in the debug console and DevTools and costs nothing in release builds.
  /// Until 0.5 every failure was `print`ed from its constructor instead,
  /// with no way to turn it off or send it anywhere else.
  void onFailure(Failure failure) {
    developer.log(
      failure.error.toString(),
      name: 'firefuel',
      error: failure.error,
      stackTrace: failure.stackTrace,
    );
  }
}

/// A [FirefuelObserver] that ignores everything, for tests or apps that
/// report failures where they handle them.
class SilentFirefuelObserver extends FirefuelObserver {
  const SilentFirefuelObserver();

  @override
  void onFailure(Failure failure) {}
}

/// When a write returned by firefuel completes.
enum WriteAcknowledgement {
  /// When the server has accepted the write. The default, and Firestore's
  /// own behaviour.
  ///
  /// While offline such a write does not complete until the connection
  /// returns, even though the local cache (and every listener) already shows
  /// it, so UI that awaits it hangs.
  server,

  /// As soon as the write is queued locally.
  ///
  /// A write the server later rejects (security rules, a document that no
  /// longer exists) is rolled back in the cache, and listeners see it
  /// revert. The failure goes to [FirefuelObserver.onFailure], because the
  /// caller has already moved on. A successful result means "applied
  /// locally", not "accepted".
  local,
}
