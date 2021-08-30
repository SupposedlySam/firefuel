import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/collection.dart';
import 'package:firefuel/src/firefuel_repository.dart';

class TestRepository<T extends Serializable?> extends FirefuelRepository<T> {
  TestRepository({required Collection<T> collection})
      : super(collection: collection);
}
