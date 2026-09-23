import 'package:firefuel/firefuel.dart';

abstract class FirefuelRepository<T extends Serializable>
    extends FirefuelQueryRepository<T>
    implements Repository<T> {
  const FirefuelRepository({required Collection<T> collection})
    : _collection = collection,
      super(source: collection);

  final Collection<T> _collection;

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
  Future<Either<Failure, void>> delete(DocumentId docId) {
    return guard(() => _collection.delete(docId));
  }

  @override
  Stream<Either<Failure, T?>> stream(DocumentId docId) {
    return guardStream(() => _collection.stream(docId));
  }

  @override
  Stream<Either<Failure, List<T?>>> streamMany(List<DocumentId> docIds) {
    return guardStream(() => _collection.streamMany(docIds));
  }

  @override
  Future<Either<Failure, T?>> read(DocumentId docId, {GetOptions? getOptions}) {
    return guard(() => _collection.read(docId, getOptions: getOptions));
  }

  @override
  Future<Either<Failure, List<T?>>> readMany(
    List<DocumentId> docIds, {
    GetOptions? getOptions,
  }) {
    return guard(() => _collection.readMany(docIds, getOptions: getOptions));
  }

  @override
  Stream<Either<Failure, FirefuelSnapshot<T?>>> docSnapshots(
    DocumentId docId, {
    ListenOptions options = const ListenOptions(),
  }) {
    return guardStream(() => _collection.docSnapshots(docId, options: options));
  }

  @override
  Future<Either<Failure, T>> readOrCreate({
    required DocumentId docId,
    required T createValue,
    GetOptions? getOptions,
  }) {
    return guard(() {
      return _collection.readOrCreate(
        docId: docId,
        createValue: createValue,
        getOptions: getOptions,
      );
    });
  }

  @override
  Future<Either<Failure, void>> replace({
    required DocumentId docId,
    required T value,
  }) {
    return guard(() => _collection.replace(docId: docId, value: value));
  }

  @override
  Future<Either<Failure, void>> replaceFields({
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
  Future<Either<Failure, void>> update({
    required DocumentId docId,
    required T value,
  }) {
    return guard(() {
      return _collection.update(docId: docId, value: value);
    });
  }

  @override
  Future<Either<Failure, void>> updateFields({
    required DocumentId docId,
    required Map<String, Object?> fields,
  }) {
    return guard(() => _collection.updateFields(docId: docId, fields: fields));
  }

  @override
  Future<Either<Failure, void>> arrayUnion({
    required DocumentId docId,
    required String field,
    required List<Object?> values,
  }) {
    return guard(
      () => _collection.arrayUnion(docId: docId, field: field, values: values),
    );
  }

  @override
  Future<Either<Failure, void>> arrayRemove({
    required DocumentId docId,
    required String field,
    required List<Object?> values,
  }) {
    return guard(
      () => _collection.arrayRemove(docId: docId, field: field, values: values),
    );
  }

  @override
  Future<Either<Failure, void>> serverTimestamp({
    required DocumentId docId,
    required String field,
  }) {
    return guard(() => _collection.serverTimestamp(docId: docId, field: field));
  }

  @override
  Future<Either<Failure, void>> increment({
    required DocumentId docId,
    required String field,
    required num by,
  }) {
    return guard(
      () => _collection.increment(docId: docId, field: field, by: by),
    );
  }

  @override
  Future<Either<Failure, void>> deleteField({
    required DocumentId docId,
    required String field,
  }) {
    return guard(() => _collection.deleteField(docId: docId, field: field));
  }

  @override
  Future<Either<Failure, T>> updateOrCreate({
    required DocumentId docId,
    required T value,
  }) {
    return guard(() => _collection.updateOrCreate(docId: docId, value: value));
  }

  @override
  Future<Either<Failure, T?>> whereById(
    DocumentId docId, {
    GetOptions? getOptions,
  }) {
    return guard(() => _collection.whereById(docId, getOptions: getOptions));
  }
}
