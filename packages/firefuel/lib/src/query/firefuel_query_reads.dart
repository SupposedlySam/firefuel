import 'package:firefuel/firefuel.dart';

/// Every query-shaped read, implemented once over a base query.
///
/// Mix it into anything that can supply [baseQuery] and [untypedBaseQuery]
/// (a collection, or a collection group) and it gets the whole read, count,
/// aggregate, pagination and stream surface. Each method builds a
/// [FirefuelQuery] and lowers it through [FirefuelQuery.applyTo], so every
/// read applies filters, order, cursors and limits the same way.
mixin FirefuelQueryReads<T extends Serializable>
    implements
        CollectionAggregate<double?>,
        CollectionCount<int>,
        CollectionPaginate<Chunk<T>, T>,
        CollectionRead<List<T>, T> {
  /// The documents every read starts from, converted to [T].
  Query<T?> get baseQuery;

  /// The same documents without conversion, for aggregations.
  Query<Map<String, dynamic>> get untypedBaseQuery;

  @override
  Future<List<T>> query(FirefuelQuery query, {GetOptions? getOptions}) async {
    final snapshot = await query.applyTo(baseQuery).get(getOptions);

    return snapshot.docs.toListT();
  }

  @override
  Stream<List<T>> streamQuery(FirefuelQuery query) {
    return query.applyTo(baseQuery).snapshots().toListT();
  }

  @override
  Future<List<T>> readAll({GetOptions? getOptions}) {
    return query(FirefuelQuery(), getOptions: getOptions);
  }

  @override
  Stream<List<T>> streamAll() => streamQuery(FirefuelQuery());

  @override
  Stream<List<T>> streamChanges({bool includeRemoved = false}) {
    return baseQuery.snapshots().toChangedListT(includeRemoved: includeRemoved);
  }

  @override
  Future<List<T>> limit(int limit, {GetOptions? getOptions}) {
    return query(FirefuelQuery(limit: limit), getOptions: getOptions);
  }

  @override
  Stream<List<T>> streamLimited(int limit) {
    return streamQuery(FirefuelQuery(limit: limit));
  }

  @override
  Future<List<T>> orderBy(
    List<OrderBy> orderBy, {
    int? limit,
    GetOptions? getOptions,
  }) {
    if (orderBy.isEmpty) throw MissingValueException(OrderBy);

    return query(
      FirefuelQuery(orderBy: orderBy, limit: limit),
      getOptions: getOptions,
    );
  }

  @override
  Stream<List<T>> streamOrdered(List<OrderBy> orderBy) {
    if (orderBy.isEmpty) throw MissingValueException(OrderBy);

    return streamQuery(FirefuelQuery(orderBy: orderBy));
  }

  @override
  Future<List<T>> where(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
    GetOptions? getOptions,
  }) {
    return query(
      _whereQuery(clauses, orderBy: orderBy, limit: limit),
      getOptions: getOptions,
    );
  }

  @override
  Stream<List<T>> streamWhere(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
  }) {
    return streamQuery(_whereQuery(clauses, orderBy: orderBy, limit: limit));
  }

  @override
  Future<Chunk<T>> paginate(Chunk<T> chunk, {GetOptions? getOptions}) async {
    final snapshot = await chunk.query
        .applyTo(baseQuery, startAfterDocument: chunk.cursor)
        .get(getOptions);

    return chunk.followedBy(
      data: snapshot.docs.toListT(),
      cursor: snapshot.docs.lastOrNull,
      isLast: snapshot.docs.length < chunk.limit,
    );
  }

  /// {@macro firefuel.rules.count.definition}
  ///
  /// {@template firefuel.collection.count}
  /// Counts on the server with Firestore's `count()` aggregation: only the
  /// number is transferred, and you are billed one read per batch of up to
  /// 1000 index entries rather than one per document.
  /// {@endtemplate}
  ///
  /// {@macro firefuel.rules.count.footer}
  @override
  Future<int> countAll({AggregateSource? source}) {
    return _count(FirefuelQuery(), source: source);
  }

  /// {@macro firefuel.rules.countwhere.definition}
  ///
  /// {@macro firefuel.collection.count}
  ///
  /// {@macro firefuel.rules.countwhere.footer}
  @override
  Future<int> countWhere(List<Clause> clauses, {AggregateSource? source}) {
    return _count(FirefuelQuery(clauses: clauses), source: source);
  }

  /// {@macro firefuel.rules.streamcount.definition}
  ///
  /// {@template firefuel.collection.streamcount}
  /// Firestore's `count()` aggregation cannot be listened to, so this
  /// streams the matching documents and reports how many there are. Every
  /// matching document is read and billed; prefer [countAll] or
  /// [countWhere] unless you need live updates.
  /// {@endtemplate}
  ///
  /// {@macro firefuel.rules.streamcount.footer}
  @override
  Stream<int> streamCountAll() {
    return baseQuery.snapshots().map((snapshot) => snapshot.size);
  }

  /// {@macro firefuel.rules.streamcountwhere.definition}
  ///
  /// {@macro firefuel.collection.streamcount}
  ///
  /// {@macro firefuel.rules.streamcountwhere.footer}
  @override
  Stream<int> streamCountWhere(List<Clause> clauses) {
    return FirefuelQuery(
      clauses: clauses,
    ).applyTo(baseQuery).snapshots().map((snapshot) => snapshot.size);
  }

  @override
  Future<double?> sumAll(String field, {AggregateSource? source}) {
    return sumWhere(const [], field, source: source);
  }

  @override
  Future<double?> sumWhere(
    List<Clause> clauses,
    String field, {
    AggregateSource? source,
  }) async {
    final snapshot = await FirefuelQuery(clauses: clauses)
        .applyTo(untypedBaseQuery)
        .aggregate(sum(field))
        .get(source: source ?? AggregateSource.server);

    return snapshot.getSum(field);
  }

  @override
  Future<double?> averageAll(String field, {AggregateSource? source}) {
    return averageWhere(const [], field, source: source);
  }

  @override
  Future<double?> averageWhere(
    List<Clause> clauses,
    String field, {
    AggregateSource? source,
  }) async {
    final snapshot = await FirefuelQuery(clauses: clauses)
        .applyTo(untypedBaseQuery)
        .aggregate(average(field))
        .get(source: source ?? AggregateSource.server);

    return snapshot.getAverage(field);
  }

  Future<int> _count(FirefuelQuery query, {AggregateSource? source}) async {
    final snapshot = await query
        .applyTo(untypedBaseQuery)
        .count()
        .get(source: source ?? AggregateSource.server);

    return snapshot.count ?? 0;
  }

  static FirefuelQuery _whereQuery(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
  }) {
    if (clauses.isEmpty) throw MissingValueException(Clause);

    return FirefuelQuery(
      clauses: clauses,
      orderBy: orderBy ?? const [],
      limit: limit,
    );
  }
}
