# Typed transactions

## Metadata
- **Type:** Feature
- **Appetite:** 3 days
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** no

## Problem
firefuel has batches but no transactions. As a result, `readOrCreate` and `replace` are
read-then-write races, and any "check then write" a consumer needs goes around firefuel.
flyby's pitch 08 already plans a rollback transaction.

## Shaping
- `Firefuel.runTransaction<R>((tx) async { ... })`. `tx` is a `FirefuelTransaction`
  exposing typed `read(collection, docId)`, `create/createById/update/updateFields/replace/delete`
  against any `FirefuelCollection`, all through that collection's converter.
- `readOrCreate` and `replace` are reimplemented on it (pitch 02 #8).
- Repository gets a `guard`ed form that returns `Either<Failure, R>`.

## How it fails
- The Firestore rule is reads before writes. It's enforced in `FirefuelTransaction` with a
  named error, not left to the platform.
- `fake_cloud_firestore` implements transactions, so they can be tested without the emulator.

## flyby's answer (2026-09-23)
**No need.** flyby runs every transaction server-side in Cloud Functions. This pitch is justified
only by pass-through completeness and by making `readOrCreate`/`replace` atomic. It goes last
among the features.

## Outcome (2026-09-23)
- `Firefuel.runTransaction((tx) async { final users = tx.of(userCollection); ... })`
  gives typed `read` and `readOrCreate` (atomic), plus create, createById, update, updateOrCreate,
  replace, updateFields and delete, all through each collection's `encode`.
- `Firefuel.batch()` returns a `FirefuelWriteBatch` with the same `.of(collection)` shape. It's
  atomic, can span collections, and never auto-commits. This follows the architecture
  review's Q4 and the creative review's point 6. `FirefuelBatch` stays as the
  single-collection bulk writer that chunks by itself.
- Named errors: `ReadAfterWriteException` (Firestore's reads-before-writes rule) and
  `MixedFirestoreInstancesException` (one instance per transaction or batch, see 03).
- `FirefuelCollection.readOrCreate` stays non-atomic and offline-safe, and its docs now point to
  the transaction version. That's the opt-in from DESIGN D4.
- **Not tested:** rollback when the handler throws. fake_cloud_firestore applies transaction
  writes immediately, and rollback is Firestore's guarantee, not firefuel's.
- **Deviation from the order in DESIGN D1:** this shipped after 05 and 06, because flyby needed
  those and not this.
