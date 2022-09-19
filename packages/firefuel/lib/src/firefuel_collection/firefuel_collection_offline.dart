import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/firefuel_collection/firefuel_collection_base.dart';
import 'package:firefuel/src/utils/serializable_extensions.dart';

/// Offline tweaks needed for certain methods to no longer freeze the UI when
/// offline.
class FirefuelCollectionOffline<T extends Serializable>
    extends FirefuelCollectionBase<T> implements Collection<T> {
  final CollectionReference<T?> _ref;

  FirefuelCollectionOffline(super.untypedRef, this._ref);

  CollectionReference<T?> get ref => _ref;

  @override
  Future<DocumentId> create(T value) {
    final docId = generateDocId();

    createById(docId: docId, value: value);

    return Future.value(docId);
  }

  @override
  Future<DocumentId> createById({
    required T value,
    required DocumentId docId,
  }) {
    ref.doc(docId.docId).set(value);

    return Future.value(docId);
  }

  @override
  Future<Null> delete(DocumentId docId) {
    ref.doc(docId.docId).delete();

    return Future.value(null);
  }

  @override
  Future<T> readOrCreate({
    required DocumentId docId,
    required T createValue,
  }) async {
    try {
      final maybeData = await read(docId);

      if (maybeData != null) return maybeData;
    } catch (e) {
      // Trying to access a value that's not present while offline will throw
      // instead of returning null

      createById(value: createValue, docId: docId);
    }

    final data = await read(docId);

    return data!;
  }

  @override
  Future<Null> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) {
    final replacement = value.toIsolatedJson(fieldPaths);

    untypedRef.doc(docId.docId).update(replacement);

    return Future.value(null);
  }

  @override
  Future<Null> update({
    required DocumentId docId,
    required T value,
  }) {
    ref.doc(docId.docId).update(value.toJson());

    return Future.value(null);
  }

  @override
  Future<T> updateOrCreate({
    required DocumentId docId,
    required T value,
  }) {
    ref.doc(docId.docId).set(value, SetOptions(merge: true));

    return Future.value(value);
  }
}
