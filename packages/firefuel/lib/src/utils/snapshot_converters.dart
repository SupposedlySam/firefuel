import 'package:firefuel/firefuel.dart';

/// Converts cloud_firestore snapshots to firefuel's.
///
/// Internal: the listening methods on collections and collection groups use
/// it.
abstract final class Snapshots {
  static FirefuelDoc<T> doc<T>(DocumentSnapshot<T?> snapshot) {
    return FirefuelDoc(
      id: snapshot.id,
      path: snapshot.reference.path,
      value: snapshot.data(),
      hasPendingWrites: snapshot.metadata.hasPendingWrites,
    );
  }

  static FirefuelQuerySnapshot<T> query<T>(QuerySnapshot<T?> snapshot) {
    final docs = snapshot.docs.map(doc).toList();

    return FirefuelQuerySnapshot(
      value: docs.map((doc) => doc.value).whereType<T>().toList(),
      docs: docs,
      changes: [
        for (final change in snapshot.docChanges)
          FirefuelDocChange(
            type: change.type,
            doc: doc(change.doc),
            oldIndex: change.oldIndex,
            newIndex: change.newIndex,
          ),
      ],
      isFromCache: snapshot.metadata.isFromCache,
      hasPendingWrites: snapshot.metadata.hasPendingWrites,
    );
  }

  static FirefuelSnapshot<T?> document<T>(DocumentSnapshot<T?> snapshot) {
    return FirefuelSnapshot(
      value: snapshot.data(),
      isFromCache: snapshot.metadata.isFromCache,
      hasPendingWrites: snapshot.metadata.hasPendingWrites,
    );
  }
}
