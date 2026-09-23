import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel/src/write_scopes.dart';

class Firefuel {
  /// The instance collections use unless they were given their own.
  ///
  /// Throws a [StateError] before [initialize] is called. (Before 0.5 this was
  /// an assert, which release builds skip, so the failure there was an
  /// unexplained null-check crash.)
  static FirebaseFirestore get firestore {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError(
        'Firefuel is not initialized: call Firefuel.initialize(firestore) '
        'before using a collection.',
      );
    }
    return firestore;
  }

  static FirebaseFirestore? _firestore;

  static String get env {
    if (_env == null) return '';
    return '$_env-';
  }

  static String? _env;

  /// Initializes Firefuel with instance of [FirebaseFirestore]
  ///
  /// This method must be called before any other method of Firefuel
  ///
  /// Collections without their own instance use [firestore], resolved each
  /// time they touch Firestore. Calling [initialize] again (for example after
  /// switching to a named database) moves every such collection over, including
  /// ones built earlier.
  ///
  /// ---
  ///
  /// [env] is optional and will be prepended to all collection names
  ///
  /// Useful for separating collections between app flavors / environments
  static void initialize(FirebaseFirestore firestore, {String? env}) {
    _env = env;
    _firestore = firestore;
  }

  /// Clears all local properties
  ///
  /// This is not required for normal use, but can be used if needing to reset
  ///  Firefuel
  static void reset() {
    _env = null;
    _firestore = null;
  }

  /// Runs [handler] as a Firestore transaction and returns its result.
  ///
  /// Scope the transaction to each collection with `transaction.of(...)`,
  /// read what you need, then write:
  ///
  /// ```dart
  /// await Firefuel.runTransaction((transaction) async {
  ///   final accounts = transaction.of(accountCollection);
  ///   final from = await accounts.read(fromId);
  ///   final to = await accounts.read(toId);
  ///
  ///   accounts
  ///     ..update(docId: fromId, value: from!.withdraw(amount))
  ///     ..update(docId: toId, value: to!.deposit(amount));
  /// });
  /// ```
  ///
  /// If a document it read changes before it commits, Firestore runs
  /// [handler] again, up to [maxAttempts] times, so [handler] must not have
  /// side effects beyond the transaction. Transactions fail while offline.
  ///
  /// Runs on [firestore], or on the default instance.
  static Future<R> runTransaction<R>(
    Future<R> Function(FirefuelTransaction transaction) handler, {
    FirebaseFirestore? firestore,
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) {
    return WriteScopes.runTransaction(
      firestore ?? Firefuel.firestore,
      handler,
      timeout: timeout,
      maxAttempts: maxAttempts,
    );
  }

  /// An atomic batch of writes that may span collections, on [firestore]
  /// or the default instance. Scope it with `batch.of(...)` and [commit].
  ///
  /// [commit]: FirefuelWriteBatch.commit
  static FirefuelWriteBatch batch({FirebaseFirestore? firestore}) {
    return WriteScopes.batch(firestore ?? Firefuel.firestore);
  }
}
