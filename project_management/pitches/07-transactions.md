# Typed transactions

## Metadata
- **Type:** Feature
- **Appetite:** 3 days
- **Status:** Pitch
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
