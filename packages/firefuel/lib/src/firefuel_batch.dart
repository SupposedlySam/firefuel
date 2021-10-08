import 'dart:async';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/serializable_extensions.dart';

class FirefuelBatch<T extends Serializable> extends Batch<T> {
  final FirefuelCollection<T> collection;

  FirefuelBatch(this.collection) : super(collection);

  @override
  Future<int?> create(T value) => transact((batch) {
        batch.set(collection.ref.doc(), value);
      });

  @override
  Future<int?> createById({required T value, required DocumentId docId}) =>
      transact((batch) {
        batch.set(collection.ref.doc(docId.docId), value);
      });

  @override
  Future<int?> delete(DocumentId docId) => transact((batch) {
        batch.delete(collection.ref.doc(docId.docId));
      });

  @override
  Future<int?> replace({required DocumentId docId, required T value}) =>
      transact((batch) async {
        final existingDoc = await collection.read(docId);

        if (existingDoc == null) return null;

        batch.set(collection.ref.doc(docId.docId), value);
      });

  @override
  Future<int?> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) =>
      transact((batch) {
        final replacement = value.getReplacement(fieldPaths);

        batch.update(collection.ref.doc(docId.docId), replacement);
      });

  @override
  Future<int?> update({required DocumentId docId, required T value}) =>
      transact((batch) {
        batch.update(collection.ref.doc(docId.docId), value.toJson());
      });
}
