import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/field_updates.dart';

/// Thrown when a transaction reads after it has written.
///
/// Firestore requires every read in a transaction to happen before its
/// first write. The platform reports a violation as an opaque error, or not
/// at all on some platforms, so firefuel names it where it happens.
class ReadAfterWriteException implements Exception {
  @override
  String toString() =>
      'ReadAfterWriteException: a transaction must do all of its reads '
      'before its first write';
}

/// Thrown when one transaction or batch is handed collections from two
/// different Firestore instances.
class MixedFirestoreInstancesException implements Exception {
  @override
  String toString() =>
      'MixedFirestoreInstancesException: every collection in a transaction '
      'or batch must use the same FirebaseFirestore instance';
}

/// The writes a transaction and a batch share, applied to one collection.
///
/// Every value is serialized through the collection's `encode`, so
/// [FieldUpdate]s (including a [ServerTimestamp] from `toJson`) behave as
/// they do in a direct write.
class WriteScope<T extends Serializable> {
  WriteScope._(_Writer writer, this.collection) : _writer = writer;

  final _Writer _writer;

  /// The collection these writes go to.
  final FirefuelCollection<T> collection;

  /// Creates [value] under a new auto-generated id, returned immediately.
  DocumentId create(T value) {
    final doc = collection.ref.doc();
    _writer.set(doc, value);
    return DocumentId(doc.id);
  }

  /// Creates or overwrites the document at [docId] with [value].
  void createById({required DocumentId docId, required T value}) {
    _writer.set(collection.ref.doc(docId.docId), value);
  }

  /// Merges [value] into the document at [docId], creating it if needed.
  void updateOrCreate({required DocumentId docId, required T value}) {
    _writer.set(
      collection.ref.doc(docId.docId),
      value,
      SetOptions(merge: true),
    );
  }

  /// Merges [value] into the existing document at [docId]. The whole
  /// write fails if it does not exist.
  void update({required DocumentId docId, required T value}) {
    _writer.update(collection.ref.doc(docId.docId), collection.encode(value));
  }

  /// Replaces the existing document at [docId] with [value]. The whole
  /// write fails if it does not exist.
  void replace({required DocumentId docId, required T value}) {
    update(docId: docId, value: value);
  }

  /// Updates [fields] of the existing document at [docId]. Values may be
  /// [FieldUpdate]s.
  void updateFields({
    required DocumentId docId,
    required Map<String, Object?> fields,
  }) {
    _writer.update(collection.ref.doc(docId.docId), FieldUpdates.lower(fields));
  }

  /// Deletes the document at [docId].
  void delete(DocumentId docId) {
    _writer.delete(collection.ref.doc(docId.docId));
  }
}

/// A transaction's view of one collection: typed reads, then writes.
class TransactionScope<T extends Serializable> extends WriteScope<T> {
  TransactionScope._(_TransactionWriter super.writer, super.collection)
    : super._();

  _TransactionWriter get _tx => _writer as _TransactionWriter;

  /// Reads the document at [docId] as part of the transaction.
  ///
  /// If another client changes it before the transaction commits, the whole
  /// transaction runs again with fresh reads.
  Future<T?> read(DocumentId docId) async {
    final snapshot = await _tx.get(collection.ref.doc(docId.docId));
    return snapshot.data();
  }

  /// Reads the document at [docId], or creates it with [createValue].
  ///
  /// Unlike `FirefuelCollection.readOrCreate`, two clients racing on the
  /// same missing document cannot both create it: the loser's transaction
  /// retries and reads the winner's document.
  Future<T> readOrCreate({
    required DocumentId docId,
    required T createValue,
  }) async {
    final existing = await read(docId);
    if (existing != null) return existing;

    createById(docId: docId, value: createValue);
    return createValue;
  }
}

/// A running transaction. Get one from `Firefuel.runTransaction`.
///
/// Scope it to each collection you touch with [of]. All reads must come
/// before the first write; reading after writing throws
/// [ReadAfterWriteException].
///
/// Transactions need the server: they fail while offline, where plain
/// writes would queue. Keep them for check-then-write logic that must be
/// atomic.
class FirefuelTransaction {
  FirefuelTransaction._(Transaction transaction, this.firestore)
    : _writer = _TransactionWriter(transaction);

  final _TransactionWriter _writer;

  /// The instance this transaction runs against.
  final FirebaseFirestore firestore;

  /// This transaction's typed view of [collection].
  TransactionScope<T> of<T extends Serializable>(
    FirefuelCollection<T> collection,
  ) {
    _checkInstance(collection, firestore);
    return TransactionScope._(_writer, collection);
  }
}

/// An atomic batch of writes that may span collections. Get one from
/// `Firefuel.batch`.
///
/// Nothing is written until [commit]; then every write lands or none do.
/// Unlike `FirefuelBatch`, it never commits part of its writes on its own.
/// Firestore rejects a batch whose request is too large (10 MiB); split very
/// large imports yourself, or use `FirefuelBatch`, which chunks for you.
class FirefuelWriteBatch {
  FirefuelWriteBatch._(this.firestore)
    : _writer = _BatchWriter(firestore.batch());

  final _BatchWriter _writer;

  /// The instance this batch writes to.
  final FirebaseFirestore firestore;

  /// This batch's typed view of [collection].
  WriteScope<T> of<T extends Serializable>(FirefuelCollection<T> collection) {
    _checkInstance(collection, firestore);
    return WriteScope._(_writer, collection);
  }

  /// Writes everything queued, atomically.
  Future<void> commit() => _writer.batch.commit();
}

/// Starts [FirefuelTransaction]s and [FirefuelWriteBatch]es.
///
/// Internal: reach these through `Firefuel.runTransaction` and
/// `Firefuel.batch`.
abstract final class WriteScopes {
  static Future<R> runTransaction<R>(
    FirebaseFirestore firestore,
    Future<R> Function(FirefuelTransaction transaction) handler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) {
    return firestore.runTransaction(
      (transaction) => handler(FirefuelTransaction._(transaction, firestore)),
      timeout: timeout,
      maxAttempts: maxAttempts,
    );
  }

  static FirefuelWriteBatch batch(FirebaseFirestore firestore) {
    return FirefuelWriteBatch._(firestore);
  }
}

void _checkInstance(
  FirefuelCollection<Serializable> collection,
  FirebaseFirestore firestore,
) {
  if (!identical(collection.firestore, firestore)) {
    throw MixedFirestoreInstancesException();
  }
}

/// The three writes Transaction and WriteBatch share, behind one interface
/// so [WriteScope] is written once.
sealed class _Writer {
  void set<D>(DocumentReference<D> doc, D data, [SetOptions? options]);
  void update(DocumentReference<Object?> doc, Map<String, Object?> data);
  void delete(DocumentReference<Object?> doc);
}

final class _BatchWriter extends _Writer {
  _BatchWriter(this.batch);

  final WriteBatch batch;

  @override
  void set<D>(DocumentReference<D> doc, D data, [SetOptions? options]) {
    batch.set(doc, data, options);
  }

  @override
  void update(DocumentReference<Object?> doc, Map<String, Object?> data) {
    batch.update(doc, data);
  }

  @override
  void delete(DocumentReference<Object?> doc) => batch.delete(doc);
}

final class _TransactionWriter extends _Writer {
  _TransactionWriter(this._transaction);

  final Transaction _transaction;
  var _hasWritten = false;

  Future<DocumentSnapshot<D>> get<D>(DocumentReference<D> doc) {
    if (_hasWritten) throw ReadAfterWriteException();
    return _transaction.get(doc);
  }

  @override
  void set<D>(DocumentReference<D> doc, D data, [SetOptions? options]) {
    _hasWritten = true;
    _transaction.set(doc, data, options);
  }

  @override
  void update(DocumentReference<Object?> doc, Map<String, Object?> data) {
    _hasWritten = true;
    _transaction.update(doc, data);
  }

  @override
  void delete(DocumentReference<Object?> doc) {
    _hasWritten = true;
    _transaction.delete(doc);
  }
}
