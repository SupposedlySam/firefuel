import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/collection.dart';
import 'package:firefuel_core/firefuel_core.dart';

abstract class FirefuelCollection<T extends Serializable>
    with FirefuelFetchMixin
    implements Collection<T> {
  final String collectionName;

  FirefuelCollection(this.collectionName);

  CollectionReference<Map<String, dynamic>> untypedCollectionRef(
    FirebaseFirestore instance,
  ) =>
      instance.collection(collectionName);

  Future<Either<FirefuelFailure, T>> getOrCreate({
    required DocumentId docId,
    required T createValue,
  }) async {
    final result = await read(docId);

    return result.fold(left, (data) async {
      if (data != null) return Right(data);

      await create(
        value: createValue,
        documentId: docId,
      );

      final readResult = await read(docId);

      return readResult.map((type) => type!);
    });
  }

  Future<Either<FirefuelFailure, T?>> read(
    DocumentId documentId,
  ) async {
    return guard(() async {
      final snapshot = await collectionRef.doc(documentId.docId).get();
      return snapshot.data();
    });
  }

  Stream<T?> readAsStream(DocumentId documentId) {
    final snapshots = collectionRef.doc(documentId.docId).snapshots();

    return snapshots.map((documentSnapshot) => documentSnapshot.data());
  }

  @override
  Future<Either<FirefuelFailure, DocumentId>> create({
    required T value,
    DocumentId? documentId,
  }) async {
    return guard(() async {
      final documentRef = documentId != null
          ? (collectionRef.doc(documentId.docId)..set(value))
          : await collectionRef.add(value);

      return DocumentId(documentRef.id);
    });
  }

  @override
  Future<Either<FirefuelFailure, Null>> update({
    required DocumentId documentId,
    required Map<String, Object?> value,
  }) {
    return guard(() async {
      await collectionRef.doc(documentId.docId).update(value);

      return null;
    });
  }

  @override
  Future<Either<FirefuelFailure, Null>> delete(DocumentId documentId) {
    return guard(() async {
      await collectionRef.doc(documentId.docId).delete();

      return null;
    });
  }

  @override
  Stream<List<T>> listenAll<T>(CollectionReference<T> collectionRef) {
    return collectionRef.snapshots().map(
          (collection) => collection.docs.map((doc) => doc.data()).toList(),
        );
  }

  @override
  Stream<T?> listen<T>(
    CollectionReference<T> collectionRef,
    DocumentId documentId,
  ) {
    return collectionRef.doc(documentId.docId).snapshots().map(
          (snapshot) => snapshot.data(),
        );
  }
}
