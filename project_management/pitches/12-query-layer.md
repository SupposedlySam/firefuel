# The query is a value

## Metadata
- **Type:** Infrastructure
- **Appetite:** 2 days
- **Status:** Pitch
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
