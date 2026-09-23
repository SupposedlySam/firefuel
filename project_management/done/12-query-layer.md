# The query is a value

## Metadata
- **Type:** Infrastructure
- **Appetite:** 2 days
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** no (public query helpers become internal)

## Problem
Every query shape is a separate method (`where`, `streamWhere`, `orderBy`, `streamOrdered`,
`limit`, `streamLimited`, `paginate`), and each lowers onto `Query` in its own way. Metadata
(05), collection groups (06), and cursors or OR (08) would each multiply against those
shapes. The paginate bug (02 #2) is a symptom: `Chunk` re-states a query by hand and dropped
half of it.

## Shaping
- `FirefuelQuery<T>` is immutable: `clauses`, `orderBy`, `limit`, `limitToLast`,
  `startAt`/`startAfter`/`endAt`/`endBefore` (values). It has **one** `applyTo(Query<T?>)`,
  which also owns the orderBy rewrite for range filters.
- The read rules gain `where`/`streamWhere` overloads by query (named `query`/`streamQuery`,
  because Dart has no overloading). The old methods become sugar.
- `Chunk` holds a `FirefuelQuery` plus the cursor, so a next page cannot lose clauses or limit.
- A `QueryReads<T>` mixin (on a base exposing `Query<T?> get baseQuery`) owns the reads, so
  06 gets them for free.
- `query_extensions.dart` and `snapshot_conversion_mixin.dart` stop being exported publicly.

See [DESIGN.md](../DESIGN.md) D2.

## Outcome (2026-09-23)
- `FirefuelQuery` (clauses, orderBy, limit, limitToLast, start/end cursors) with a single
  `applyTo`, which also owns the range-ordering rewrite. Start and end cursors are sealed
  `StartCursor` and `EndCursor`, per the architecture review.
- `FirefuelQueryReads<T>` is a mixin holding every query-shaped read over `baseQuery`.
  `FirefuelCollection` mixes it in. Collection groups (06) will too.
- `query` / `streamQuery` added to `CollectionRead` and the repository.
- `Chunk` holds the query, and each page is derived from the previous one
  (`followedBy`), so the class of bug fixed in 02 #2 can't recur.
- `QueryX` is internal. flyby didn't use it (checked 2026-09-23).
- Found while building: fake_cloud_firestore applies query operations in call
  order, so a cursor added after a limit selects the wrong page. Cursors now go
  through `applyTo(startAfterDocument:)`, before limits.
- **Declined:** renaming the rules from `Collection*` to `Query*` (architecture review Q3).
  It would break everyone who names them and buy nothing a collection group needs.
- Pitch 08's cursors and `limitToLast` came along with the query value. What's left in 08
  is OR/AND and multi-aggregate.
