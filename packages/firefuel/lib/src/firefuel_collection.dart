import 'dart:async';

import 'package:firefuel/firefuel.dart';

abstract class FirefuelCollection<T extends Serializable>
    implements Collection<T> {
  final String path;

  final firestore = Firefuel.firestore;

  FirefuelCollection(String path, {bool useEnv = true})
      : this.path = _buildPath(path, useEnv);

  @override
  CollectionReference<T?> get ref {
    return untypedRef.withConverter(
      fromFirestore: fromFirestore,
      toFirestore: toFirestore,
    );
  }

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

  /// Auto-generate a [DocumentId]
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  DocumentId generateDocId() => DocumentId(ref.doc().id);

  @override
  Future<List<T>> limit(int limit) async {
    final snapshot = await ref.limit(limit).get();

    return snapshot.docs.toListT();
  }

  @override
  Future<List<T>> orderBy(List<OrderBy> orderBy, {int? limit}) async {
    if (orderBy.isEmpty) throw MissingValueException(OrderBy);

    final query = ref.sort(orderBy).limitIfNotNull(limit);

    final snapshot = await query.get();

    return snapshot.docs.toListT();
  }

  @override
  Future<Chunk<T>> paginate(Chunk<T> chunk) async {
    final snapshot = await _buildPaginationSnapshot(chunk);

    final data = snapshot.docs.toListT();
    final cursor = snapshot.size == 0 ? null : snapshot.docs.last;

    final snapshotLength = snapshot.docs.length;
    final isNotLast = snapshotLength == chunk.limit;

    return isNotLast
        ? Chunk<T>.next(
            data: data,
            cursor: cursor,
            orderBy: chunk.orderBy,
          )
        : Chunk<T>.last(
            data: data,
            cursor: cursor,
            orderBy: chunk.orderBy,
          );
  }

  @override
  Future<T?> read(DocumentId docId) async {
    final snapshot = await ref.doc(docId.docId).get();
    return snapshot.data();
  }

  @override
  Future<List<T>> readAll() async {
    final snapshot = await ref.get();

    return snapshot.docs.toListT();
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

  @override
  Stream<T?> stream(DocumentId docId) {
    return ref.doc(docId.docId).snapshots().toMaybeT();
  }

  @override
  Stream<List<T>> streamAll() {
    return ref.snapshots().toListT();
  }

  @override
  Stream<List<T>> streamLimited(int limit) {
    return ref.limit(limit).snapshots().toListT();
  }

  @override
  Stream<List<T>> streamOrdered(List<OrderBy> orderBy) {
    return ref.sort(orderBy).snapshots().toListT();
  }

  @override
  Stream<List<T>> streamWhere(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
  }) {
    final query = _getWhereWithOrderByAndLimitQuery(
      clauses: clauses,
      orderBy: orderBy,
      limit: limit,
    );

    return query.snapshots().toListT();
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

  @override
  Future<List<T>> where(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
  }) async {
    final query = _getWhereWithOrderByAndLimitQuery(
      clauses: clauses,
      orderBy: orderBy,
      limit: limit,
    );

    final snapshot = await query.get();

    return snapshot.docs.toListT();
  }

  /// Get the Documents used to create a [Chunk] when paginating data from a
  /// Collection
  ///
  /// Orders and limits the [ref] and returns the [QuerySnapshot]
  Future<QuerySnapshot<T?>> _buildPaginationSnapshot(Chunk<T> chunk) async {
    var query = ref
        .filterIfNotNull(chunk.clauses)
        .sortIfNotNull(chunk.orderBy)
        .startAfterIfNotNull(chunk.cursor)
        .limitIfNotNull(chunk.limit);

    return query.get();
  }

  Query<T?> _getWhereWithOrderByAndLimitQuery({
    required List<Clause> clauses,
    required List<OrderBy>? orderBy,
    required int? limit,
  }) {
    if (clauses.isEmpty) {
      throw MissingValueException(Clause);
    } else if (Clause.hasMoreThanOneFieldInRangeComparisons(clauses)) {
      throw MoreThanOneFieldInRangeClauseException();
    }

    final augmentedOrderBys = OrderBy.moveOrCreateMatchingField(
      fieldToMatch: clauses.first.field,
      orderBy: orderBy,
      isRangeComparison: Clause.hasRangeComparison(clauses),
    );

    final processedOrderBys = OrderBy.removeEqualtyAndInMatchingFields(
      fieldsToMatch: Clause.getEqualityOrInComparisonFields(clauses),
      orderBy: augmentedOrderBys,
      isEqualityOrInComparison: Clause.hasEqualityOrInComparison(clauses),
    );

    return ref
        .filter(clauses)
        .sortIfNotNull(processedOrderBys)
        .limitIfNotNull(limit);
  }

  static String _buildPath(String path, bool useEnv) {
    if (useEnv) return '${Firefuel.env}$path';

    return path;
  }
}
