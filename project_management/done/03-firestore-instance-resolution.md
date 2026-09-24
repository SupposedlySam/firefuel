# Resolve the Firestore instance when it's used, not when the collection is built

## Metadata
- **Type:** Feature / Fix
- **Appetite:** 1 day
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** no

## Problem
`FirefuelCollection` does `final FirebaseFirestore firestore = Firefuel.firestore;` when it
is constructed. flyby switches between named databases at runtime
(`FirebaseFirestore.instanceFor(databaseId:)`). After a switch, collections built earlier
keep writing to the old database, and nothing raises an error. Its FCM handler also works
with an injected instance instead of `UserCollection` (flyby
`app_remote_data_message_context.dart:106`).

## Evidence
flyby audit G and C (2026-09-23).

## Shaping
- `FirefuelCollection(path, {FirebaseFirestore? firestore, bool useEnv = true})`. When an
  instance is given, the collection is pinned to it. Otherwise `firestore` is a **getter** that
  resolves `Firefuel.firestore` on every use.
- `Firefuel.initialize` can be called again to switch the default database. This is
  documented as the supported way to swap databases.
- `FirefuelBatch` and transactions use the collection's instance. A batch spanning two
  instances is an error, and it is raised when the op is queued.

## How it fails
- Calling `Firefuel.firestore` before `initialize` fails today with an `assert`, and in
  release builds it is a null-check crash. Replace that with a named `StateError` saying
  `Firefuel.initialize` has not been called.

## flyby's answer (2026-09-23)
G is **latent, not live**: nothing dispatches `UpdateDatabase`, and the database is chosen
once, before `Firefuel.initialize`. C is foreground code that could use
`UserCollection.updateFields` today. flyby wants the optional `FirebaseFirestore? firestore`
constructor param, mainly for tests. **Priority: low.** Keep the lazy getter, because it
costs nothing and removes a latent trap.

## Outcome (2026-09-23)
Shipped as shaped. The first test passed against a `late final` mutation because it never used
the collection before switching, so it was tightened to read first; it now fails on that mutation.
Batches take the instance once, when they are created, which is the right scope for a batch.
