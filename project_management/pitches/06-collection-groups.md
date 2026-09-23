# Typed collection groups

## Metadata
- **Type:** Feature
- **Appetite:** 2 days
- **Status:** Pitch
- **Created:** 2026-09-23
- **Breaking:** no

## Problem
`collectionGroup` queries every subcollection with the same id. firefuel has no typed form
for it, so flyby's reactions run a raw, untyped listener.

## Shaping
- `FirefuelCollectionGroup<T>` shares the converter contract (`fromFirestore`, `toFirestore`)
  and implements the **read-only** rules: `CollectionRead`, `CollectionCount`,
  `CollectionAggregate`, `CollectionPaginate`. It has no create and no docId-based reads,
  because a group has no single parent.
- The query-building code (filter, sort, limit, cursors) comes out of `FirefuelCollection`
  into a shared query layer, so that both types use it.
- A matching `FirefuelCollectionGroupRepository`, or a generic repository over the read
  rules. Decide with the architecture review.

## flyby's answer (2026-09-23)
Would adopt; it replaces the raw reactions listener. The same `where`/`streamWhere`/`Clause`
API is needed, and **callers must be able to recover parent ids from the doc path**, since
reactions need the message-pod id.
