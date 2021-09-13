import 'package:cloud_firestore/cloud_firestore.dart';

extension QuerySnapshotX<T> on Stream<QuerySnapshot<T?>> {
  /// Get all non-null data from the [QuerySnapshot] documents
  Stream<List<T>> toListT() {
    return map(
      (snapshot) => snapshot.docs.toListT(),
    );
  }
}

extension QueryDocumentSnapshotX<T> on List<QueryDocumentSnapshot<T?>> {
  /// Get all non-null data from [QueryDocumentSnapshot] as a [List]
  List<T> toListT() {
    return map((doc) => doc.data()).whereType<T>().toList();
  }
}

extension DocumentSnapshotX<T> on Stream<DocumentSnapshot<T?>> {
  /// Get data from the [DocumentSnapshot]
  Stream<T?> toMaybeT() {
    return map((snapshot) => snapshot.data());
  }
}
