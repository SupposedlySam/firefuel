import 'package:dartz/dartz.dart';
import 'package:firefuel/firefuel.dart';
import 'package:firefuel_core/firefuel_core.dart';

abstract class Repository<T> {
  Future<Either<FirefuelFailure, DocumentId>> create({
    required T value,
    DocumentId docId,
  });

  Future<Either<FirefuelFailure, T?>> read(DocumentId docId);

  Stream<T?> readAsStream(DocumentId docId);

  Future<Either<FirefuelFailure, Null>> update({
    required DocumentId docId,
    required T value,
  });

  Future<Either<FirefuelFailure, Null>> delete(DocumentId docId);
}
