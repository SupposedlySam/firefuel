# Server values and multi-field updates

## Metadata
- **Type:** Feature
- **Appetite:** 2 days
- **Status:** Pitch
- **Created:** 2026-09-23
- **Breaking:** no

## Problem
Writing a server timestamp while creating a document means overriding `create` and
`createById`, dropping to `untypedRef`, and patching the JSON by hand (flyby
`message_pod_collection.dart:59-87`). An update that mixes `arrayUnion` with a plain set is
one `updateFields` call with a raw `FieldValue`; firefuel's helpers handle one field per call.
`FieldValue.increment` and `FieldValue.delete` have no firefuel helper at all.

## Evidence
flyby audit D and E. Issue #43 (batch create + replace).

## Shaping
- **Field updates as values.** A sealed `FieldUpdate` (`FieldUpdate.set(v)`,
  `.increment(n)`, `.arrayUnion(xs)`, `.arrayRemove(xs)`, `.delete()`,
  `.serverTimestamp()`) accepted by `updateFields` next to plain values. It lowers to
  `FieldValue` in one place and works in collections, batches and transactions.
  `increment` and `deleteField` become one-line helpers like `arrayUnion`.
- **Server timestamp on create.** `toFirestore` may return `FieldValue` sentinels already,
  because Firestore accepts them in `set`. What flyby lacks is a *typed* way to say "this model
  field is server-set". Open question: a `serverTimestampFields` override on the collection,
  or telling users to return `FieldValue.serverTimestamp()` from `toFirestore` and documenting it.
- `Timestamp` ↔ `DateTime` conversion helpers (`TimestampConverter`), since every consumer
  writes this by hand.

## Open Questions
- Does firefuel own the sentinel, or does it document `FieldValue` in `toFirestore`? The
  second adds nothing to the API. Needs flyby's view.

## flyby's answer (2026-09-23)
Both features would be adopted. The sentinel should be a const `FirefuelServerTimestamp()`
that a model's `toJson` returns, resolved on create/createById/update/updateOrCreate
(it deletes two overrides in `MessagePodCollection`). `FieldUpdate` should be a list form:
`updateFields(docId, [FieldUpdate.set(f, v), FieldUpdate.arrayUnion(f, [...]), ...])`, with the
`Map` form kept. flyby notes the sentinel alone won't remove its 8-attempt retry. A read option
for `ServerTimestampBehavior.estimate`, or a write that returns the local snapshot, would.
