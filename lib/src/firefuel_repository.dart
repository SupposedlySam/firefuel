import 'package:dartz/dartz.dart';
import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/collection.dart';
import 'package:firefuel/src/repository.dart';
import 'package:firefuel_core/firefuel_core.dart';

abstract class FirefuelRepository<T extends Serializable>
    with FirefuelFetchMixin
    implements Repository<T> {
  final Collection<T> _collection;

  const FirefuelRepository({required Collection<T> collection})
      : _collection = collection;

  @override
  Future<Either<FirefuelFailure, DocumentId>> create({
    required T value,
    DocumentId? docId,
  }) {
    return guard(() => _collection.create(docId: docId, value: value));
  }

  @override
  Future<Either<FirefuelFailure, T?>> read(DocumentId docId) async {
    return guard(() => _collection.read(docId));
  }

  @override
  Stream<T?> readAsStream(DocumentId docId) {
    return _collection.readAsStream(docId);
  }

  @override
  Future<Either<FirefuelFailure, Null>> update({
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
  Future<Either<FirefuelFailure, Null>> delete(DocumentId docId) {
    return guard(() => _collection.delete(docId));
  }
}
