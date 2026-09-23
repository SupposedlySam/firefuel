# Query power: OR, cursors, multi-aggregate

## Metadata
- **Type:** Feature
- **Appetite:** 3 days
- **Status:** Pitch
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
