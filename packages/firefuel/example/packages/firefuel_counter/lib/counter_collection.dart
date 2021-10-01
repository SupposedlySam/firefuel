import 'package:firefuel/firefuel.dart';

import 'package:firefuel_counter/counter_model.dart';

class CounterCollection extends FirefuelCollection<Counter> {
  CounterCollection() : super('counter');

  /// Increases the value of the stored counter by the provided [counter]
  Future<Counter> increment({
    required DocumentId docId,
    required Counter counter,
  }) {
    return _createIfNotExists(
      docId: docId,
      createValue: counter,
      onRead: (currentCounter) async {
        final incrementedCounter = currentCounter.add(counter);

        await update(docId: docId, value: incrementedCounter);

        return incrementedCounter;
      },
    );
  }

  /// Decreases the value of the stored counter by the provided [counter]
  Future<Counter> decrement({
    required DocumentId docId,
    required Counter counter,
  }) {
    return _createIfNotExists(
      docId: docId,
      createValue: counter,
      onRead: (currentCounter) async {
        final decrementedCounter = currentCounter.subtract(counter);

        await update(docId: docId, value: decrementedCounter);

        return decrementedCounter;
      },
    );
  }

  Future<Counter> _createIfNotExists({
    required DocumentId docId,
    required Counter createValue,
    required Future<Counter> Function(Counter) onRead,
  }) async {
    final maybeData = await read(docId);

    if (maybeData != null) return onRead(maybeData);

    await createById(value: createValue, docId: docId);

    final data = await read(docId);

    return data!;
  }

  @override
  Counter? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    if (data == null) return null;

    return Counter.fromJson(data, snapshot.id);
  }

  @override
  Map<String, Object?> toFirestore(Counter? model, SetOptions? options) =>
      model?.toJson() ?? {};
}
