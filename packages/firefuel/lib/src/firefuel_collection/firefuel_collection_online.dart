import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/firefuel_collection/firefuel_collection_base.dart';
import 'package:firefuel/src/utils/serializable_extensions.dart';

class FirefuelCollectionOnline<T extends Serializable>
    extends FirefuelCollectionBase<T> implements Collection<T> {
  final CollectionReference<T?> _ref;

  FirefuelCollectionOnline(super.untypedRef, this._ref);

  CollectionReference<T?> get ref => _ref;

  @override
  Future<DocumentId> create(T value) async {
    final documentRef = await ref.add(value);

    return DocumentId(documentRef.id);
  }

  @override
  Future<DocumentId> createById({
    required T value,
    required DocumentId docId,
  }) async {
    await ref.doc(docId.docId).set(value);

    return docId;
  }

  @override
  Future<Null> delete(DocumentId docId) async {
    await ref.doc(docId.docId).delete();

    return null;
  }

  @override
  Future<T> readOrCreate({
    required DocumentId docId,
    required T createValue,
  }) async {
    final maybeData = await read(docId);

    if (maybeData != null) return maybeData;

    await createById(value: createValue, docId: docId);

    final data = await read(docId);

    return data!;
  }

  @override
  Future<Null> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) async {
    final replacement = value.toIsolatedJson(fieldPaths);

    await untypedRef.doc(docId.docId).update(replacement);

    return null;
  }

  @override
  Future<Null> update({
    required DocumentId docId,
    required T value,
  }) async {
    await ref.doc(docId.docId).update(value.toJson());

    return null;
  }

  @override
  Future<T> updateOrCreate({
    required DocumentId docId,
    required T value,
  }) async {
    await ref.doc(docId.docId).set(value, SetOptions(merge: true));

    return value;
  }
}
