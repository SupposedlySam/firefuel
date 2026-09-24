import 'package:firefuel/firefuel.dart';

enum ChunkStatus { nextAvailable, last }

/// One page of a paginated read, and everything needed to fetch the next.
///
/// Pass a [Chunk] to `paginate`, then pass the returned [Chunk] back to get
/// the following page, until [status] is [ChunkStatus.last].
///
/// Every page carries the same [query]: the next page is derived from the
/// previous one rather than re-assembled from parts. Before 0.5 each page
/// was rebuilt field by field, and the clauses and limit were silently
/// dropped after page one.
class Chunk<T> {
  /// The first page of a query described by its parts.
  Chunk({
    List<OrderBy>? orderBy,
    List<Clause>? clauses,
    int limit = defaultLimit,
  }) : this.query(
         FirefuelQuery(
           orderBy: orderBy ?? const [],
           clauses: clauses ?? const [],
           limit: limit,
         ),
       );

  /// The first page of [query], [defaultLimit] documents at a time unless
  /// the query sets its own limit.
  ///
  /// Paging walks forward from the start of the order, so a query using
  /// `limitToLast` or a start cursor cannot be paginated.
  Chunk.query(FirefuelQuery query)
    : this._first(query, query.limit ?? defaultLimit);

  Chunk._first(FirefuelQuery query, this.limit)
    : query = _forPaging(query, limit),
      data = const [],
      cursor = null,
      status = ChunkStatus.nextAvailable;

  Chunk.next({
    required this.data,
    required this.cursor,
    List<OrderBy>? orderBy,
    List<Clause>? clauses,
    this.limit = defaultLimit,
  }) : query = FirefuelQuery(
         orderBy: orderBy ?? const [],
         clauses: clauses ?? const [],
         limit: limit,
       ),
       status = ChunkStatus.nextAvailable;

  Chunk.last({
    required this.data,
    required this.cursor,
    List<OrderBy>? orderBy,
    List<Clause>? clauses,
    this.limit = defaultLimit,
  }) : query = FirefuelQuery(
         orderBy: orderBy ?? const [],
         clauses: clauses ?? const [],
         limit: limit,
       ),
       status = ChunkStatus.last;

  Chunk._page({
    required this.query,
    required this.limit,
    required this.data,
    required this.cursor,
    required this.status,
  });

  static const int defaultLimit = 25;

  /// The query every page of this pagination reads from.
  final FirefuelQuery query;

  /// The last document of this page; the next page starts after it.
  final DocumentSnapshot<T?>? cursor;

  /// The documents on this page.
  final List<T> data;

  final ChunkStatus status;

  /// Page size. Always set: every constructor fills it, and [query] carries
  /// the same value.
  final int limit;

  List<OrderBy> get orderBy => query.orderBy;

  List<Clause> get clauses => query.clauses;

  /// The page after this one, holding [data] and ending at [cursor].
  ///
  /// Used by `paginate`; you should not need to call it.
  Chunk<T> followedBy({
    required List<T> data,
    required DocumentSnapshot<T?>? cursor,
    required bool isLast,
  }) {
    return Chunk._page(
      query: query,
      limit: limit,
      data: data,
      cursor: cursor,
      status: isLast ? ChunkStatus.last : ChunkStatus.nextAvailable,
    );
  }

  static FirefuelQuery _forPaging(FirefuelQuery query, int limit) {
    if (query.limitToLast != null || query.start != null) {
      throw ArgumentError(
        'paginate walks forward from the start of the order; '
        'limitToLast and start cursors cannot be paginated',
      );
    }

    return query.copyWith(limit: limit);
  }
}
