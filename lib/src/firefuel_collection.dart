import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel_core/firefuel_core.dart';

import 'package:firefuel/src/collection.dart';

abstract class FirefuelCollection<T extends Serializable>
    implements Collection<T> {
  final String collectionName;

  FirefuelCollection(this.collectionName);

  @override
  Future<DocumentId> create({required T value, DocumentId? docId}) async {
    final documentRef = docId != null
        ? (collectionRef.doc(docId.docId)..set(value))
        : await collectionRef.add(value);

    return DocumentId(documentRef.id);
  }

  @override
  Future<Null> delete(DocumentId docId) async {
    await collectionRef.doc(docId.docId).delete();

    return null;
  }

  Future<T> getOrCreate({
    required DocumentId docId,
    required T createValue,
  }) async {
    final maybeData = await read(docId);

    if (maybeData != null) return maybeData;

    await create(
      value: createValue,
      docId: docId,
    );

    final data = await read(docId);

    return data!;
  }

  @override
  Stream<T?> listen<T>(
    CollectionReference<T?> collectionRef,
    DocumentId docId,
  ) {
    return collectionRef.doc(docId.docId).snapshots().map(
          (snapshot) => snapshot.data(),
        );
  }

  @override
  Stream<List<T>> listenAll<T>(CollectionReference<T?> collectionRef) {
    return collectionRef.snapshots().map(
          (collection) =>
              collection.docs.map((doc) => doc.data()).whereType<T>().toList(),
        );
  }

  Future<T?> read(DocumentId docId) async {
    final snapshot = await collectionRef.doc(docId.docId).get();
    return snapshot.data();
  }

  Stream<T?> readAsStream(DocumentId docId) {
    final snapshots = collectionRef.doc(docId.docId).snapshots();

    return snapshots.map((documentSnapshot) => documentSnapshot.data());
  }

  CollectionReference<Map<String, dynamic>> untypedCollectionRef(
    FirebaseFirestore instance,
  ) {
    return instance.collection(collectionName);
  }

  @override
  Future<Null> update({
    required DocumentId docId,
    required Map<String, Object?> value,
  }) async {
    await collectionRef.doc(docId.docId).update(value);

    return null;
  }
}
