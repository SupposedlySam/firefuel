import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';

abstract class Batch<T extends Serializable>
    implements
        DocCreate<int?, T>,
        DocDelete<int?>,
        DocReplace<int?, T>,
        DocUpdate<int?, T> {
  final FirefuelCollection<T> collection;
  WriteBatch _batch;

  Batch(this.collection) : _batch = collection.firestore.batch();

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

  /// Commits all transactions in the batch.
  ///
  /// returns the number of Transactions committed &
  /// resets the [size] of the batch.
  ///
  /// If the batch is empty, this method will return 0.
  ///
  /// [commit] should be called after all transactions have been added to the batch.
  ///
  /// {@macro firefuel.batch.size}
  Future<int> commit() async {
    await _batch.commit();

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
  Future<int?> transact(FutureOr<void> Function(WriteBatch) action) async {
    // increment the size of the batch
    _size++;

    // if the batch is full, commit it
    int? transactionsCommitted;
    if (_size >= maxSize) {
      transactionsCommitted = await commit();
    }

    // execute the action
    await action(_batch);

    // returns the number of Transactions committed
    // if the batch was full, otherwise returns null
    return transactionsCommitted;
  }
}
