import 'package:firefuel/firefuel.dart';

abstract class FirefuelRepository<T extends Serializable>
    with FirefuelFetchMixin
    implements Repository<T> {
  final Collection<T> _collection;

  const FirefuelRepository({required Collection<T> collection})
      : _collection = collection;

  @override
  Future<Either<Failure, DocumentId>> create(T value) {
    return guard(() => _collection.create(value));
  }

  @override
  Future<Either<Failure, DocumentId>> createById({
    required T value,
    required DocumentId docId,
  }) {
    return guard(() => _collection.createById(docId: docId, value: value));
  }

  @override
  Future<Either<Failure, Null>> delete(DocumentId docId) {
    return guard(() => _collection.delete(docId));
  }

  @override
  Future<Either<Failure, List<T>>> limit(int limit) {
    return guard(() => _collection.limit(limit));
  }

  @override
  Stream<Either<Failure, T?>> stream(DocumentId docId) {
    return guardStream(() => _collection.stream(docId));
  }

  @override
  Stream<Either<Failure, List<T>>> streamAll() {
    return guardStream(() => _collection.streamAll());
  }

  @override
  Stream<Either<Failure, List<T>>> streamLimited(int limit) {
    return guardStream(() => _collection.streamLimited(limit));
  }

  @override
  Stream<Either<Failure, List<T>>> streamOrdered(List<OrderBy> orderBy) {
    return guardStream(() => _collection.streamOrdered(orderBy));
  }

  @override
  Stream<Either<Failure, List<T>>> streamWhere(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
  }) {
    return guardStream(() => _collection.streamWhere(clauses, limit: limit));
  }

  @override
  Future<Either<Failure, List<T>>> orderBy(
    List<OrderBy> orderBy, {
    int? limit,
  }) {
    return guard(() => _collection.orderBy(orderBy, limit: limit));
  }

  @override
  Future<Either<Failure, Chunk<T>>> paginate(Chunk<T> chunk) {
    return guard(() => _collection.paginate(chunk));
  }

  @override
  Future<Either<Failure, T?>> read(DocumentId docId) async {
    return guard(() => _collection.read(docId));
  }

  @override
  Future<Either<Failure, List<T>>> readAll() async {
    return guard(() => _collection.readAll());
  }

  @override
  Future<Either<Failure, T>> readOrCreate({
    required DocumentId docId,
    required T createValue,
  }) {
    return guard(() {
      return _collection.readOrCreate(
        docId: docId,
        createValue: createValue,
      );
    });
  }

  @override
  Future<Either<Failure, Null>> replace({
    required DocumentId docId,
    required T value,
  }) {
    return guard(() => _collection.replace(docId: docId, value: value));
  }

  @override
  Future<Either<Failure, Null>> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) {
    return guard(() {
      return _collection.replaceFields(
        docId: docId,
        value: value,
        fieldPaths: fieldPaths,
      );
    });
  }

  @override
  Future<Either<Failure, Null>> update({
    required DocumentId docId,
    required T value,
  }) async {
    return guard(() {
      return _collection.update(
        docId: docId,
        value: value,
      );
    });
  }

  @override
  Future<Either<Failure, T>> updateOrCreate({
    required DocumentId docId,
    required T value,
  }) {
    return guard(() => _collection.updateOrCreate(docId: docId, value: value));
  }

  @override
  Future<Either<Failure, List<T>>> where(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
  }) {
    return guard(() => _collection.where(clauses, limit: limit));
  }

  @override
  Future<Either<Failure, T?>> whereById(DocumentId docId) {
    return guard(() => _collection.whereById(docId));
  }
}
