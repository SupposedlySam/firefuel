import 'package:dartz/dartz.dart';
import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/collection.dart';
import 'package:firefuel/src/repository.dart';
import 'package:firefuel_core/firefuel_core.dart';

abstract class FirefuelRepository<T extends Serializable>
    implements Repository<T> {
  final Collection<T> _collection;

  const FirefuelRepository({required Collection<T> collection})
      : _collection = collection;

  @override
  Future<Either<FirefuelFailure, DocumentId>> create({
    required T value,
    DocumentId? documentId,
  }) {
    return _collection.create(documentId: documentId, value: value);
  }

  @override
  Future<Either<FirefuelFailure, T?>> read(DocumentId documentId) async {
    return _collection.read(documentId);
  }

  @override
  Stream<T?> readAsStream(DocumentId documentId) {
    return _collection.readAsStream(documentId);
  }

  @override
  Future<Either<FirefuelFailure, Null>> update({
    required DocumentId documentId,
    required T value,
  }) async {
    return _collection.update(
      documentId: documentId,
      value: value.toJson(),
    );
  }

  @override
  Future<Either<FirefuelFailure, Null>> delete(DocumentId documentId) {
    return _collection.delete(documentId);
  }
}
