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
  Future<int> commit() => _commitBatch();

  @override
  Future<int?> create(T value) => _transact((batch) {
        batch.set(collection.ref.doc(), value);
      });

  @override
  Future<int?> createById({required T value, required DocumentId docId}) =>
      _transact((batch) {
        batch.set(collection.ref.doc(docId.docId), value);
      });

  @override
  Future<int?> delete(DocumentId docId) => _transact((batch) {
        batch.delete(collection.ref.doc(docId.docId));
      });

  @override
  Future<int?> replace({required DocumentId docId, required T value}) =>
      _transact((batch) async {
        final existingDoc = await collection.read(docId);

        if (existingDoc == null) return null;

        batch.set(collection.ref.doc(docId.docId), value);
      });

  @override
  Future<int?> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) =>
      _transact((batch) {
        final replacement = value.getReplacement(fieldPaths);

        batch.update(collection.ref.doc(docId.docId), replacement);
      });

  @override
  Future<int?> update({required DocumentId docId, required T value}) =>
      _transact((batch) {
        batch.update(collection.ref.doc(docId.docId), value.toJson());
      });

  @override
  Future<int?> updateOrCreate({required DocumentId docId, required T value}) =>
      _transact((batch) {
        batch.set(
            collection.ref.doc(docId.docId), value, SetOptions(merge: true));
      });
}

mixin _BatchMixin<T extends Serializable> on Batch<T> {
  late WriteBatch _batch;

  /// {@template firefuel.batch.size}
  /// Each request adds 1 to the size of the batch.
  ///
  /// [size] is greater than or equal to [maxSize] (500),
  /// the batch will be automatically be committed.
  /// {@endtemplate}
  var _size = 0;

  /// {@template firefuel.batch.maxSize}
  /// The maximum [size] of transactions that can be committed
  /// at once
  ///
  /// Max: **500** Transactions
  /// {@endtemplate}
  final maxSize = 500;

  /// {@macro firefuel.batch.size}
  int get size => _size;

  /// {@template firefuel.batch.total_transactions}
  /// The total number of transactions in the batch
  /// that have been committed
  /// {@endtemplate}
  var _totalTransactionsCommitted = 0;

  /// {@macro firefuel.batch.total_transactions}
  int get totalTransactionsCommitted => _totalTransactionsCommitted;

  /// creates a new batch &
  /// disposes the current batch.
  ///
  /// resets the [size] of the batch.
  void _createNewBatch() {
    // reset the size to reflect a new batch
    _size = 0;
    _batch = collection.firestore.batch();
  }

  @visibleForTesting
  WriteBatch get batch => _batch;

  /// Commits all transactions in the batch.
  ///
  /// returns the number of Transactions committed &
  /// resets the [size] of the batch.
  ///
  /// If the batch is empty, this method will return 0.
  ///
  /// [_commitBatch] should be called after all transactions have been added to the batch.
  ///
  /// {@macro firefuel.batch.size}
  Future<int> _commitBatch() async {
    await batch.commit();

    // add the number of Transactions  to the total
    _totalTransactionsCommitted += _size;

    // get the amount of transactions that were committed
    final committed = size;

    // dispose old batch & create new one
    _createNewBatch();

    // returns the number of Transactions committed
    return committed;
  }

  /// The method used to add a new transaction to the batch.
  Future<int?> _transact(FutureOr<void> Function(WriteBatch) action) async {
    // increment the size of the batch
    _size++;

    // if the batch is full, commit it
    int? transactionsCommitted;
    if (_size >= maxSize) {
      transactionsCommitted = await _commitBatch();
    }

    // execute the action
    await action(batch);

    // returns the number of Transactions committed
    // if the batch was full, otherwise returns null
    return transactionsCommitted;
  }
}
