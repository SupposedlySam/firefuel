import 'package:dartz/dartz.dart';
import 'package:firefuel_core/firefuel_core.dart';

import 'package:firefuel/firefuel.dart';

abstract class Repository<T> {
  Future<Either<Failure, DocumentId>> create({
    required T value,
    DocumentId docId,
  });

  Future<Either<Failure, T?>> read(DocumentId docId);

  Stream<Either<Failure, T?>> readAsStream(DocumentId docId);

  Future<Either<Failure, Null>> update({
    required DocumentId docId,
    required T value,
  });

  Future<Either<Failure, Null>> delete(DocumentId docId);
}