import 'package:firefuel/firefuel.dart';

abstract class Collection<T extends Serializable>
    implements
        CollectionAggregate<double?>,
        CollectionCount<int>,
        CollectionPaginate<Chunk<T>, T>,
        CollectionRead<List<T>, T>,
        DocCreate<DocumentId, T>,
        DocCreateIfNotExist<T, T>,
        DocDelete<void>,
        DocRead<T?>,
        DocReadMany<List<T?>>,
        DocReplace<void, T>,
        DocUpdate<void, T> {
  const Collection(); // coverage:ignore-line

  CollectionReference<T?> get ref;
}
