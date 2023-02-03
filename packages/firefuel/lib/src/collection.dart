import 'package:firefuel/firefuel.dart';

abstract class Collection<T extends Serializable>
    implements
        CollectionCount<int>,
        CollectionPaginate<Chunk<T>, T>,
        CollectionRead<List<T>, T>,
        DocCreate<DocumentId, T>,
        DocCreateIfNotExist<T, T>,
        DocDelete<Null>,
        DocRead<T?>,
        DocReplace<Null, T>,
        DocUpdate<Null, T> {
  const Collection(); // coverage:ignore-line

  CollectionReference<T?> get ref;
}
