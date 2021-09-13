import 'package:dartz/dartz.dart';
import 'package:firefuel_core/firefuel_core.dart';

import 'package:firefuel/src/rules.dart';

abstract class Repository<T extends Serializable>
    implements
        CollectionRead<Either<Failure, List<T>>, T>,
        DocCreate<Either<Failure, DocumentId>, T>,
        DocCreateIfNotExist<Either<Failure, T>, T>,
        DocDelete<Either<Failure, Null>>,
        DocRead<Either<Failure, T?>>,
        DocReplace<Either<Failure, Null>, T>,
        DocUpdate<Either<Failure, Null>, T> {}
