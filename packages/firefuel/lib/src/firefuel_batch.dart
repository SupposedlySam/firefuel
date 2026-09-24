import 'dart:async';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/field_updates.dart';
import 'package:flutter/foundation.dart';

class FirefuelBatch<T extends Serializable> extends Batch<T> with _BatchMixin {
  FirefuelBatch(super.collection) {
    _createNewBatch();
  }

  @override
  Future<void> commit() async {
    await _commitBatch();

    _createNewBatch();
  }

  @override
  Future<void> create(T value) async {
    await _addToBatch((batch) {
      batch.set(collection.ref.doc(), value);
    });
  }

  @override
  Future<void> createById({required T value, required DocumentId docId}) async {
    await _addToBatch((batch) {
      batch.set(collection.ref.doc(docId.docId), value);
    });
  }

  @override
  Future<void> delete(DocumentId docId) async {
    await _addToBatch((batch) {
      batch.delete(collection.ref.doc(docId.docId));
    });
  }

  @override
  Future<void> replace({required DocumentId docId, required T value}) async {
    // Reading here would run before the batch commits, so a createById
    // earlier in the same batch was invisible and the replace was silently
    // dropped (#43). update() checks existence at commit instead.
    await _addToBatch((batch) {
      batch.update(collection.ref.doc(docId.docId), collection.encode(value));
    });
  }

  @override
  Future<void> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) async {
    await _addToBatch((batch) {
      batch.update(
        collection.ref.doc(docId.docId),
        collection.encodeFields(value, fieldPaths),
      );
    });
  }

  @override
  void reset() => _createNewBatch();

  @override
  Future<void> update({required DocumentId docId, required T value}) async {
    await _addToBatch((batch) {
      batch.update(collection.ref.doc(docId.docId), collection.encode(value));
    });
  }

  @override
  Future<void> updateFields({
    required DocumentId docId,
    required Map<String, Object?> fields,
  }) async {
    await _addToBatch((batch) {
      batch.update(collection.ref.doc(docId.docId), FieldUpdates.lower(fields));
    });
  }

  @override
  Future<void> arrayUnion({
    required DocumentId docId,
    required String field,
    required List<Object?> values,
  }) {
    return updateFields(
      docId: docId,
      fields: {field: FieldUpdate.arrayUnion(values)},
    );
  }

  @override
  Future<void> arrayRemove({
    required DocumentId docId,
    required String field,
    required List<Object?> values,
  }) {
    return updateFields(
      docId: docId,
      fields: {field: FieldUpdate.arrayRemove(values)},
    );
  }

  @override
  Future<void> serverTimestamp({
    required DocumentId docId,
    required String field,
  }) {
    return updateFields(
      docId: docId,
      fields: {field: const FieldUpdate.serverTimestamp()},
    );
  }

  @override
  Future<void> increment({
    required DocumentId docId,
    required String field,
    required num by,
  }) {
    return updateFields(
      docId: docId,
      fields: {field: FieldUpdate.increment(by)},
    );
  }

  @override
  Future<void> deleteField({required DocumentId docId, required String field}) {
    return updateFields(
      docId: docId,
      fields: {field: const FieldUpdate.delete()},
    );
  }

  @override
  Future<void> updateOrCreate({
    required DocumentId docId,
    required T value,
  }) async {
    await _addToBatch((batch) {
      batch.set(
        collection.ref.doc(docId.docId),
        value,
        SetOptions(merge: true),
      );
    });
  }
}

mixin _BatchMixin<T extends Serializable> on Batch<T> {
  late WriteBatch _batch;

  /// {@template firefuel.batch.size}
  /// Each request adds 1 to the size of the batch.
  ///
  /// [transactionSize] is greater than or equal to [transactionLimit] (500),
  /// the batch will be automatically be committed.
  /// {@endtemplate}
  var _transactionSize = 0;

  /// {@template firefuel.batch.total_transactions}
  /// The total number of transactions in the batch that have been committed
  /// {@endtemplate}
  var _totalTransactionsCommitted = 0;

  @visibleForTesting
  WriteBatch get batch => _batch;

  /// {@macro firefuel.batch.total_transactions}
  int get totalTransactionsCommitted => _totalTransactionsCommitted;

  /// {@template firefuel.batch.maxSize}
  /// The maximum [transactionSize] of transactions that can be committed
  /// at once
  ///
  /// Max: **500** Transactions
  /// {@endtemplate}
  int get transactionLimit => 500;

  /// {@macro firefuel.batch.size}
  int get transactionSize => _transactionSize;

  /// The method used to add a new transaction to the batch.
  ///
  /// Automatically commits the current batch and creates a new one when the
  /// [transactionLimit] is reached
  Future<void> _addToBatch(FutureOr<void> Function(WriteBatch) action) async {
    // Roll over before adding, so the op that does not fit starts the next
    // batch and is counted there. Counting first (as before 0.5) committed
    // 499 ops, then left the rolled-over op uncounted in the new batch.
    if (_transactionSize >= transactionLimit) {
      await _commitBatch();

      _createNewBatch();
    }

    await action(batch);

    _transactionSize++;
  }

  Future<void> _commitBatch() async {
    await batch.commit();

    // add the number of Transactions  to the total
    _totalTransactionsCommitted += _transactionSize;
  }

  /// creates a new batch
  ///
  /// resets the [transactionSize] of the batch.
  void _createNewBatch() {
    // reset the size to reflect a new batch
    _transactionSize = 0;
    _batch = collection.firestore.batch();
  }
}
