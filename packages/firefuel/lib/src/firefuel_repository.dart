import 'package:dartz/dartz.dart';
import 'package:firefuel_core/firefuel_core.dart';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/collection.dart';
import 'package:firefuel/src/repository.dart';

abstract class FirefuelRepository<T extends Serializable>
    with FirefuelFetchMixin
    implements Repository<T> {
  final Collection<T> _collection;

  const FirefuelRepository({required Collection<T> collection})
      : _collection = collection;

  @override
  Future<Either<Failure, DocumentId>> create({
    required T value,
    DocumentId? docId,
  }) {
    return guard(() => _collection.create(value));
  }

  @override
  Future<Either<Failure, T?>> read(DocumentId docId) async {
    return guard(() => _collection.read(docId));
  }

  @override
  Stream<Either<Failure, T?>> readAsStream(DocumentId docId) {
    return guardStream(() => _collection.readAsStream(docId));
  }

  @override
  Future<Either<Failure, Null>> update({
    required DocumentId docId,
    required T value,
  }) async {
    return guard(() {
      return _collection.update(
        docId: docId,
        value: value.toJson(),
      );
    });
  }

  @override
  Future<Either<Failure, Null>> delete(DocumentId docId) {
    return guard(() => _collection.delete(docId));
  }
}
