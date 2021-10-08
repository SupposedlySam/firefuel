import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';

abstract class Batch<T extends Serializable>
    implements
        DocCreate<int?, T>,
        DocDelete<int?>,
        DocReplace<int?, T>,
        DocUpdate<int?, T> {
  final FirefuelCollection<T> collection;
  final WriteBatch batch;

  Batch(this.collection) : batch = collection.firestore.batch();
}
