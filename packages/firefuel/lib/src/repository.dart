import 'package:firefuel/firefuel.dart';

abstract class Repository<T extends Serializable>
    implements
        CollectionRead<Either<Failure, List<T>>, T>,
        CollectionPaginate<Either<Failure, Chunk<T>>, T>,
        DocCreate<Either<Failure, DocumentId>, T>,
        DocCreateIfNotExist<Either<Failure, T>, T>,
        DocDelete<Either<Failure, Null>>,
        DocRead<Either<Failure, T?>>,
        DocReplace<Either<Failure, Null>, T>,
        DocUpdate<Either<Failure, Null>, T> {
  const Repository(); // coverage:ignore-line
}
