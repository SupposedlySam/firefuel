import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/serializable_extensions.dart';
import 'package:flutter/foundation.dart';

class FirefuelBatch<T extends Serializable> extends Batch<T> with _BatchMixin {
  final FirefuelCollection<T> collection;

  FirefuelBatch(this.collection) : super(collection) {
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
    await _addToBatch((batch) async {
      final existingDoc = await collection.read(docId);

      if (existingDoc == null) return null;

      batch.set(collection.ref.doc(docId.docId), value);
    });
  }

  @override
  Future<void> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) async {
    await _addToBatch((batch) {
      final replacement = value.toIsolatedJson(fieldPaths);

      batch.update(collection.ref.doc(docId.docId), replacement);
    });
  }

  @override
  void reset() => _createNewBatch();

  @override
  Future<void> update({required DocumentId docId, required T value}) async {
    await _addToBatch((batch) {
      batch.update(collection.ref.doc(docId.docId), value.toJson());
    });
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
    // increment the size of the batch
    _transactionSize++;

    // if the batch is full, commit it
    if (_transactionSize >= transactionLimit) {
      await _commitBatch();

      _createNewBatch();
    }

    // execute the action
    await action(batch);
  }

  /// Commits all transactions in the batch.
  ///
  /// Calling this method prevents any future operations from being added.
  ///
  /// Should be called after all transactions have been added to the batch.
  ///
  /// {@macro firefuel.batch.size}
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
