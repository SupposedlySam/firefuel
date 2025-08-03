import 'dart:async';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/serializable_extensions.dart';

abstract class FirefuelCollection<T extends Serializable>
    implements Collection<T> {
  FirefuelCollection(String path, {bool useEnv = true})
      : path = _buildPath(path, useEnv);
  final String path;

  final firestore = Firefuel.firestore;

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

  /// {@macro firefuel.rules.count.definition}
  ///
  /// {@template firefuel.collection.count}
  /// Uses the count feature introduced in v4.0.0 of `cloud_firestore` to count
  /// documents on the server without retrieving documents.
  ///
  /// > ## Firestore Release Notes
  /// > Cloud Firestore now supports a count() aggregation query that allows you
  /// > to determine the number of documents in a collection. The server
  /// > calculates the count, and transmits only the result, a single integer,
  /// > back to your app, saving on both billed document reads and bytes
  /// > transferred, compared to executing the full query.
  ///
  /// > Source: https://firebase.google.com/support/releases#firestore-count-queries
  /// {@endtemplate}
  ///
  /// {@macro firefuel.rules.count.footer}
  @override
  Future<int> countAll({GetOptions? getOptions}) async {
    final snapshot = await untypedRef.count().get();

    return snapshot.count ?? 0;
  }

  /// {@macro firefuel.rules.countwhere.definition}
  ///
  /// {@macro firefuel.collection.count}
  ///
  /// {@macro firefuel.rules.countwhere.footer}
  @override
  Future<int> countWhere(List<Clause> clauses, {GetOptions? getOptions}) async {
    final snapshot = await untypedRef.filter(clauses).count().get();

    return snapshot.count ?? 0;
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
  Future<void> delete(DocumentId docId) async {
    await ref.doc(docId.docId).delete();

    return;
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
  Future<List<T>> limit(
    int limit, {
    GetOptions? getOptions,
  }) async {
    final snapshot = await ref.limit(limit).get(getOptions);

    return snapshot.docs.toListT();
  }

  @override
  Future<List<T>> orderBy(
    List<OrderBy> orderBy, {
    int? limit,
    GetOptions? getOptions,
  }) async {
    if (orderBy.isEmpty) throw MissingValueException(OrderBy);

    final query = ref.sort(orderBy).limitIfNotNull(limit);

    final snapshot = await query.get(getOptions);

    return snapshot.docs.toListT();
  }

  @override
  Future<Chunk<T>> paginate(Chunk<T> chunk, {GetOptions? getOptions}) async {
    final snapshot = await _buildPaginationSnapshot(
      chunk,
      getOptions: getOptions,
    );

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
  Future<T?> read(DocumentId docId, {GetOptions? getOptions}) async {
    final snapshot = await ref.doc(docId.docId).get(getOptions);
    return snapshot.data();
  }

  @override
  Future<List<T>> readAll({GetOptions? getOptions}) async {
    final snapshot = await ref.get(getOptions);

    return snapshot.docs.toListT();
  }

  @override
  Future<T> readOrCreate({
    required DocumentId docId,
    required T createValue,
    GetOptions? getOptions,
  }) async {
    final maybeData = await read(docId, getOptions: getOptions);

    if (maybeData != null) return maybeData;

    await createById(value: createValue, docId: docId);

    final data = await read(docId, getOptions: getOptions);

    return data!;
  }

  @override
  Future<void> replace({
    required DocumentId docId,
    required T value,
    GetOptions? getOptions,
  }) async {
    final existingDoc = await read(docId, getOptions: getOptions);

    if (existingDoc == null) return;

    await ref.doc(docId.docId).set(value);

    return;
  }

  @override
  Future<void> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) async {
    final replacement = value.toIsolatedJson(fieldPaths);

    await untypedRef.doc(docId.docId).update(replacement);

    return;
  }

  @override
  Stream<T?> stream(DocumentId docId) {
    return ref.doc(docId.docId).snapshots().toMaybeT();
  }

  @override
  Stream<List<T>> streamAll() {
    return ref.snapshots().toListT();
  }

  /// {@macro firefuel.rules.streamcount.definition}
  ///
  /// {@template firefuel.collection.streamcount}
  /// This method DOES NOT use the server side count function provided by
  /// v4.0.0 of `cloud_firestore` as they do not currenly support streams.
  ///
  /// See [countAll] and [countWhere] for more details.
  ///
  /// This method works by streaming documents from Firestore and accessing the
  /// size property once the full query is executed. This method will incur
  /// document reads and bytes transferred.
  ///
  /// As per the Google's recommendation, you shouldn't need to worry about
  /// optimnizing for reads until it becomes a problem. Depending on the size of
  /// your app, it may never need to be optimized.
  /// {@endtemplate}
  ///
  /// {@macro firefuel.rules.streamcount.footer}
  @override
  Stream<int> streamCountAll() {
    final snapshots = ref.snapshots();

    return snapshots.map((querySnapshot) => querySnapshot.size);
  }

  /// {@macro firefuel.rules.streamcountwhere.definition}
  ///
  /// {@macro firefuel.collection.streamcount}
  ///
  /// {@macro firefuel.rules.streamcountwhere.footer}
  @override
  Stream<int> streamCountWhere(List<Clause> clauses) {
    final snapshots = ref.filter(clauses).snapshots();

    return snapshots.map((querySnapshot) => querySnapshot.size);
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

  /// Converts a [T?] to a [`Map<String, Object?>`] to upload to Firestore.
  Map<String, Object?> toFirestore(
    T? model,
    SetOptions? options,
  );

  @override
  Future<void> update({
    required DocumentId docId,
    required T value,
  }) async {
    await ref.doc(docId.docId).update(value.toJson());

    return;
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
    GetOptions? getOptions,
  }) async {
    final query = _getWhereWithOrderByAndLimitQuery(
      clauses: clauses,
      orderBy: orderBy,
      limit: limit,
    );

    final snapshot = await query.get(getOptions);

    return snapshot.docs.toListT();
  }

  @override
  Future<T?> whereById(DocumentId docId, {GetOptions? getOptions}) async {
    final snapshot = await ref
        .where(
          FieldPath.documentId,
          isEqualTo: docId.docId,
        )
        .get(getOptions);

    final docs = snapshot.docs;

    if (docs.isEmpty) return null;

    return docs.first.data();
  }

  /// Get the Documents used to create a [Chunk] when paginating data from a
  /// Collection
  ///
  /// Orders and limits the [ref] and returns the [QuerySnapshot]
  Future<QuerySnapshot<T?>> _buildPaginationSnapshot(
    Chunk<T> chunk, {
    GetOptions? getOptions,
  }) async {
    final query = ref
        .filterIfNotNull(chunk.clauses)
        .sortIfNotNull(chunk.orderBy)
        .startAfterIfNotNull(chunk.cursor)
        .limitIfNotNull(chunk.limit);

    return query.get(getOptions);
  }

  // Creates a query to filter, sort, and limit the collection
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

  /// Prefix the collection path with the environment
  ///
  /// if the environment isn't provided, the path is returned unaltered.
  static String _buildPath(String path, bool useEnv) {
    if (useEnv) return '${Firefuel.env}$path';

    return path;
  }
}
