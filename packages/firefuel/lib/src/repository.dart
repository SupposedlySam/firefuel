import 'package:firefuel/firefuel.dart';

abstract class Repository<T extends Serializable>
    implements
        CollectionCount<Either<Failure, int>>,
        CollectionRead<Either<Failure, List<T>>, T>,
        CollectionPaginate<Either<Failure, Chunk<T>>, T>,
        DocCreate<Either<Failure, DocumentId>, T>,
        DocCreateIfNotExist<Either<Failure, T>, T>,
        DocDelete<Either<Failure, void>>,
        DocRead<Either<Failure, T?>>,
        DocReplace<Either<Failure, void>, T>,
        DocUpdate<Either<Failure, void>, T> {
  const Repository(); // coverage:ignore-line
}
