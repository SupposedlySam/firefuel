import 'package:firefuel/firefuel.dart';

abstract class Batch<T extends Serializable>
    implements
        DocCreate<void, T>,
        DocDelete<void>,
        DocReplace<void, T>,
        DocUpdate<void, T>,
        DocUpdateOrCreate<void, T> {
  final FirefuelCollection<T> collection;

  Batch(this.collection);

  /// Commits the current batch of transactions
  ///
  /// Keeps the existing batch and transactionSize
  Future<void> commit();

  /// Commits all transactions and creates a new batch
  Future<void> complete();

  /// Creates a new batch without commiting the current transactions
  void reset();
}
