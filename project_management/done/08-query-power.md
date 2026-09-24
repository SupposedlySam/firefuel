# Query power: OR, cursors, multi-aggregate

## Metadata
- **Type:** Feature
- **Appetite:** 3 days
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** no

## Problem
Firestore has supported OR and AND composite filters (`Filter.or`, `Filter.and`) since
2023. Issue #35, open since 2021, asks for them. Cursors other than `startAfterDocument`
aren't reachable (`startAt`, `endAt`, `endBefore`, `limitToLast`). Nor are several
aggregations in one round trip (`aggregate(count(), sum(a), average(b))`).

## Shaping
- `Clause.or([...])` and `Clause.and([...])` compose into one `Filter`. The existing
  `List<Clause>` means AND, as it always has. Lowering: `QueryX.filter` builds a single `Filter`.
- `where`/`streamWhere` take an optional `QueryCursor` (a sealed type:
  `startAt`/`startAfter`/`endAt`/`endBefore`, by values or by document), plus `limitToLast`.
- `aggregate(List<Clause>?, {count, sum: [...], average: [...]})` returns one
  `AggregateResult`.
- `Chunk` supports descending pagination and keeps its clauses and limit (the fix in pitch 02).

## Out of scope
- Firestore Pipelines (`firestore.pipeline()`). They're Enterprise-edition only and a whole
  different query model. It's recorded in `pass-through.md` as declined for now.

## flyby's answer (2026-09-23)
**No current need.** Message lists paginate from local storage. Justified by issue #35 and
pass-through completeness.

## Outcome (2026-09-23)
- `Clause` is sealed ([DESIGN.md](../DESIGN.md) D7). `Clause(field, ...)` still compiles and returns
  a `FieldClause`, and `Clause.or([...])`/`Clause.and([...])` return a `ClauseGroup` that lowers to
  `Filter.or`/`Filter.and`. Groups nest. The orderBy rewrite reads top-level field clauses only.
  This closes issue #35.
- `aggregate(FirefuelQuery, {count, sums, averages, source})` returns an `AggregateResult` in
  one round trip. It's on collections, groups and repositories (new `QueryAggregate` rule).
- Cursors, `limitToLast` and descending pagination already shipped with 12.
- `Clause.hasMoreThanOneFieldInRangeComparisons` is deprecated (unused since 02).
- **Breaking:** code that read `Clause` properties (`clause.field`) through a `Clause`-typed variable
  must now match `FieldClause`. That's unlikely outside firefuel.
- Issue #34 (`isNotEqualTo` on numbers) is **obsolete**: Firestore has supported `!=` natively
  since 2020. It's left open on GitHub because firefuel-owner doesn't comment publicly. Closing it
  is for the maintainer.
