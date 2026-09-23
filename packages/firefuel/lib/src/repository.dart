import 'package:firefuel/firefuel.dart';

/// [ReadableQuery]'s reads, each returning `Either<Failure, R>`.
abstract class QueryRepository<T extends Serializable>
    implements
        CollectionAggregate<Either<Failure, double?>>,
        CollectionCount<Either<Failure, int>>,
        CollectionRead<Either<Failure, List<T>>, T>,
        CollectionPaginate<Either<Failure, Chunk<T>>, T>,
        QueryAggregate<Either<Failure, AggregateResult>>,
        QueryListen<Either<Failure, FirefuelQuerySnapshot<T>>> {}

abstract class Repository<T extends Serializable>
    implements
        QueryRepository<T>,
        DocCreate<Either<Failure, DocumentId>, T>,
        DocCreateIfNotExist<Either<Failure, T>, T>,
        DocListen<Either<Failure, FirefuelSnapshot<T?>>>,
        DocDelete<Either<Failure, void>>,
        DocRead<Either<Failure, T?>>,
        DocReadMany<Either<Failure, List<T?>>>,
        DocReplace<Either<Failure, void>, T>,
        DocUpdate<Either<Failure, void>, T> {
  const Repository(); // coverage:ignore-line
}
