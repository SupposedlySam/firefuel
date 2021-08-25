import 'package:dartz/dartz.dart';
import 'package:firefuel/firefuel.dart';
import 'package:firefuel_core/firefuel_core.dart';

abstract class Repository<T> {
  Future<Either<FirefuelFailure, DocumentId>> create({
    required T value,
    DocumentId documentId,
  });

  Future<Either<FirefuelFailure, T?>> read(DocumentId documentId);

  Stream<T?> readAsStream(DocumentId documentId);

  Future<Either<FirefuelFailure, Null>> update({
    required DocumentId documentId,
    required T value,
  });

  Future<Either<FirefuelFailure, Null>> delete(DocumentId documentId);
}
