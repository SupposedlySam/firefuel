import 'dart:async';

import 'package:firefuel/firefuel.dart';

abstract class FirefuelCollection<T extends Serializable>
    implements Collection<T> {
  final String path;

  FirefuelCollection(this.path);

  final firestore = Firefuel.firestore;

  @override
  CollectionReference<T?> get ref {
    return untypedRef.withConverter(
      fromFirestore: fromFirestore,
      toFirestore: toFirestore,
    );
  }

  @override
  Stream<List<T>> get stream => listenAll();

  CollectionReference<Map<String, dynamic>> get untypedRef {
    return firestore.collection(path);
  }

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

  /// Converts a [DocumentSnapshot] to a [T?]
  T? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  @override
  Stream<T?> listen(DocumentId docId) {
    return ref.doc(docId.docId).snapshots().toMaybeT();
  }

  @override
  Stream<List<T>> listenAll() {
    return ref.snapshots().toListT();
  }

  Stream<List<T>> listenWhere(Iterable<Clause> clauses, {int? limit}) {
    final filteredQuery = _queryFromClauses(clauses);
    final query = limit == null ? filteredQuery : filteredQuery.limit(limit);

    return query.snapshots().toListT();
  }

  @override
  Future<T?> read(DocumentId docId) async {
    final snapshot = await ref.doc(docId.docId).get();
    return snapshot.data();
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
  Future<Null> replace({
    required DocumentId docId,
    required T value,
  }) async {
    final existingDoc = await read(docId);

    if (existingDoc == null) return null;

    await ref.doc(docId.docId).set(value);

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

    await untypedRef.doc(docId.docId).update(replacement);

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

  Future<List<T>> where(Iterable<Clause> clauses, {int? limit}) async {
    final filteredQuery = _queryFromClauses(clauses);
    final query = limit == null ? filteredQuery : filteredQuery.limit(limit);
    final snapshot = await query.get();

    return snapshot.docs.toListT();
  }

  Query<T?> _queryFromClauses(Iterable<Clause> clauses) {
    if (clauses.isEmpty) throw MissingValueException(Clause);

    return clauses.fold(ref, (result, clause) {
      return result.where(
        clause.field,
        isEqualTo: clause.isEqualTo,
        isNotEqualTo: clause.isNotEqualTo,
        isLessThan: clause.isLessThan,
        isLessThanOrEqualTo: clause.isLessThanOrEqualTo,
        isGreaterThan: clause.isGreaterThan,
        isGreaterThanOrEqualTo: clause.isGreaterThanOrEqualTo,
        arrayContains: clause.arrayContains,
        whereIn: clause.whereIn,
        whereNotIn: clause.whereNotIn,
        isNull: clause.isNull,
      );
    });
  }
}
