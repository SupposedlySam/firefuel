import 'package:firefuel/firefuel.dart';

abstract class Batch<T extends Serializable>
    implements
        DocCreate<void, T>,
        DocDelete<void>,
        DocReplace<void, T>,
        DocUpdate<void, T>,
        DocUpdateOrCreate<void, T> {
  Batch(this.collection);
  final FirefuelCollection<T> collection;

  /// Commits the current batch of transactions
  ///
  /// Keeps the existing batch and transactionSize
  Future<void> commit();

  /// Creates a new batch without commiting the current transactions
  void reset();
}
