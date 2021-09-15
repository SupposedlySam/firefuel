import 'package:firefuel/firefuel.dart';

abstract class Collection<T extends Serializable>
    implements
        CollectionRead<List<T>, T>,
        CollectionPaginate<Chunk<T>, T>,
        DocCreate<DocumentId, T>,
        DocCreateIfNotExist<T, T>,
        DocDelete<Null>,
        DocRead<T?>,
        DocReplace<Null, T>,
        DocUpdate<Null, T> {
  const Collection();

  CollectionReference<T?> get ref;

  Stream<List<T>> get stream;
}
