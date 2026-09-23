import 'package:firefuel/firefuel.dart';

/// Wraps any [ReadableQuery] so every read returns `Either<Failure, R>`
/// instead of throwing.
///
/// Extend it for a collection group; [FirefuelRepository] extends it for a
/// collection and adds the document reads and writes.
abstract class FirefuelQueryRepository<T extends Serializable>
    with FirefuelFetchMixin
    implements QueryRepository<T> {
  const FirefuelQueryRepository({required ReadableQuery<T> source})
    : _source = source;

  final ReadableQuery<T> _source;

  @override
  Future<Either<Failure, int>> countAll({AggregateSource? source}) {
    return guard(() => _source.countAll(source: source));
  }

  @override
  Future<Either<Failure, int>> countWhere(
    List<Clause> clauses, {
    AggregateSource? source,
  }) {
    return guard(() => _source.countWhere(clauses, source: source));
  }

  @override
  Future<Either<Failure, double?>> sumAll(
    String field, {
    AggregateSource? source,
  }) {
    return guard(() => _source.sumAll(field, source: source));
  }

  @override
  Future<Either<Failure, double?>> sumWhere(
    List<Clause> clauses,
    String field, {
    AggregateSource? source,
  }) {
    return guard(() => _source.sumWhere(clauses, field, source: source));
  }

  @override
  Future<Either<Failure, double?>> averageAll(
    String field, {
    AggregateSource? source,
  }) {
    return guard(() => _source.averageAll(field, source: source));
  }

  @override
  Future<Either<Failure, double?>> averageWhere(
    List<Clause> clauses,
    String field, {
    AggregateSource? source,
  }) {
    return guard(() => _source.averageWhere(clauses, field, source: source));
  }

  @override
  Future<Either<Failure, List<T>>> limit(int limit, {GetOptions? getOptions}) {
    return guard(() => _source.limit(limit, getOptions: getOptions));
  }

  @override
  Stream<Either<Failure, List<T>>> streamAll() {
    return guardStream(_source.streamAll);
  }

  @override
  Stream<Either<Failure, List<T>>> streamChanges({
    bool includeRemoved = false,
  }) {
    return guardStream(
      () => _source.streamChanges(includeRemoved: includeRemoved),
    );
  }

  @override
  Stream<Either<Failure, int>> streamCountAll() {
    return guardStream(_source.streamCountAll);
  }

  @override
  Stream<Either<Failure, int>> streamCountWhere(List<Clause> clauses) {
    return guardStream(() => _source.streamCountWhere(clauses));
  }

  @override
  Stream<Either<Failure, List<T>>> streamLimited(int limit) {
    return guardStream(() => _source.streamLimited(limit));
  }

  @override
  Stream<Either<Failure, List<T>>> streamOrdered(List<OrderBy> orderBy) {
    return guardStream(() => _source.streamOrdered(orderBy));
  }

  @override
  Stream<Either<Failure, List<T>>> streamWhere(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
  }) {
    return guardStream(
      () => _source.streamWhere(clauses, orderBy: orderBy, limit: limit),
    );
  }

  @override
  Future<Either<Failure, List<T>>> orderBy(
    List<OrderBy> orderBy, {
    int? limit,
    GetOptions? getOptions,
  }) {
    return guard(
      () => _source.orderBy(orderBy, limit: limit, getOptions: getOptions),
    );
  }

  @override
  Future<Either<Failure, Chunk<T>>> paginate(
    Chunk<T> chunk, {
    GetOptions? getOptions,
  }) {
    return guard(() => _source.paginate(chunk, getOptions: getOptions));
  }

  @override
  Future<Either<Failure, List<T>>> query(
    FirefuelQuery query, {
    GetOptions? getOptions,
  }) {
    return guard(() => _source.query(query, getOptions: getOptions));
  }

  @override
  Stream<Either<Failure, List<T>>> streamQuery(FirefuelQuery query) {
    return guardStream(() => _source.streamQuery(query));
  }

  @override
  Stream<Either<Failure, FirefuelQuerySnapshot<T>>> snapshots(
    FirefuelQuery query, {
    ListenOptions options = const ListenOptions(),
  }) {
    return guardStream(() => _source.snapshots(query, options: options));
  }

  @override
  Future<Either<Failure, List<T>>> readAll({GetOptions? getOptions}) {
    return guard(() => _source.readAll(getOptions: getOptions));
  }

  @override
  Future<Either<Failure, List<T>>> where(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
    GetOptions? getOptions,
  }) {
    return guard(
      () => _source.where(
        clauses,
        orderBy: orderBy,
        limit: limit,
        getOptions: getOptions,
      ),
    );
  }

  @override
  Future<Either<Failure, AggregateResult>> aggregate(
    FirefuelQuery query, {
    bool count = false,
    List<String> sums = const [],
    List<String> averages = const [],
    AggregateSource? source,
  }) {
    return guard(
      () => _source.aggregate(
        query,
        count: count,
        sums: sums,
        averages: averages,
        source: source,
      ),
    );
  }
}
