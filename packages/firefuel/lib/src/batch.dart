import 'package:firefuel/firefuel.dart';

abstract class Batch<T extends Serializable>
    implements
        DocCreate<int?, T>,
        DocDelete<int?>,
        DocReplace<int?, T>,
        DocUpdate<int?, T> {
  final FirefuelCollection<T> collection;

  Batch(this.collection);

  Future<int> commit();
}
