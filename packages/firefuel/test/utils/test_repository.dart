import 'package:firefuel/firefuel.dart';

class TestRepository<T extends Serializable> extends FirefuelRepository<T> {
  TestRepository({required super.collection});
}
