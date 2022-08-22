import 'package:firefuel/firefuel.dart';

import 'package:firefuel_counter/counter_collection.dart';
import 'package:firefuel_counter/counter_model.dart';

/// Abstracts the logic required to interact with the database
///
/// With the below code, we now have the ability to do the following
///
/// ```dart
/// final result = await counterRepo.decrement(
///   docId: DocumentId('counter'),
///   counter: Counter(value: 1000, id: 'someSnapshotId'), // create if not exists or reduce by 1000
/// );
///
/// result.fold(
///   (failure) => // do something with the Failure,
///   (success) => // do something with the Counter,
/// );
/// ```
///
/// without needing to know that it's actually doing a `updateOrCreate`
/// request to firestore.
class CounterRepository extends FirefuelRepository<Counter> {
  CounterRepository({required CounterCollection collection})
      : _collection = collection,
        super(collection: collection);

  final CounterCollection _collection;

  /// Increases the value of the stored counter by the provided [counter]
  Future<Either<Failure, Counter>> increment({
    required DocumentId docId,
    required Counter counter,
  }) {
    return guard(() {
      return _collection.increment(
        docId: docId,
        counter: counter,
      );
    });
  }

  /// Decreases the value of the stored counter by the provided [counter]
  Future<Either<Failure, Counter>> decrement({
    required DocumentId docId,
    required Counter counter,
  }) {
    return guard(() {
      return _collection.decrement(
        docId: docId,
        counter: counter,
      );
    });
  }
}
