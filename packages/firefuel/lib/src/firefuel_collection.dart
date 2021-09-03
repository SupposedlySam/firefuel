import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel_core/firefuel_core.dart';

import 'package:firefuel/src/collection.dart';

abstract class FirefuelCollection<T extends Serializable>
    implements Collection<T> {
  final String collectionPath;
  final FirebaseFirestore firestore;

  const FirefuelCollection(this.collectionPath, {required this.firestore});

  @override
  CollectionReference<T?> get collectionRef {
    return untypedCollectionRef.withConverter(
      fromFirestore: fromFirestore,
      toFirestore: toFirestore,
    );
  }

  @override
  Stream<List<T>> get stream => listenAll(collectionRef);

  CollectionReference<Map<String, dynamic>> get untypedCollectionRef {
    return firestore.collection(collectionPath);
  }

  @override
  Future<DocumentId> create(T value) async {
    final documentRef = await collectionRef.add(value);

    return DocumentId(documentRef.id);
  }

  @override
  Future<Null> createById({
    required T value,
    required DocumentId docId,
  }) async {
    await collectionRef.doc(docId.docId).set(value);

    return null;
  }

  @override
  Future<Null> delete(DocumentId docId) async {
    await collectionRef.doc(docId.docId).delete();

    return null;
  }

  /// Converts a [DocumentSnapshot] to a [T?]
  T? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

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
  Future<Null> replace({
    required DocumentId docId,
    required T value,
  }) async {
    final existingDoc = await read(docId);

    if (existingDoc == null) return null;

    await collectionRef.doc(docId.docId).set(value);

    return null;
  }

  @override
  Future<Null> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) async {
    final paths =
        fieldPaths.map((field) => FieldPath.fromString(field)).toList();
    final replacement = value.toJson()
      ..removeWhere((key, _) => !paths.contains(FieldPath.fromString(key)));

    await untypedCollectionRef.doc(docId.docId).update(replacement);

    return null;
  }

  /// Converts a [T?] to a [Map<String, Object?>] to upload to Firestore.
  Map<String, Object?> toFirestore(
    T? model,
    SetOptions? options,
  );

  @override
  Future<Null> update({
    required DocumentId docId,
    required T value,
  }) async {
    await collectionRef.doc(docId.docId).update(value.toJson());

    return null;
  }

  @override
  Future<Null> updateOrCreate({
    required DocumentId docId,
    required T value,
  }) async {
    await collectionRef.doc(docId.docId).set(value, SetOptions(merge: true));

    return null;
  }
}
