// Package imports:
import 'package:firefuel/firefuel.dart';

// Project imports:
import 'package:flutter_counter/counter/data/domain/counter_model.dart';

class CounterCollection extends FirefuelCollection<Counter> {
  CounterCollection() : super('counter');

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
