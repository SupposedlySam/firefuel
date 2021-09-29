import 'package:firefuel/firefuel.dart';
import 'package:flutter_counter/counter/data/collection/counter_collection.dart';
import 'package:flutter_counter/counter/data/domain/counter_model.dart';

class CounterRepository extends FirefuelRepository<Counter> {
  CounterRepository({required CounterCollection collection})
      : super(collection: collection);
}
