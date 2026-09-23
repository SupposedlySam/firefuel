# Writes that don't hang offline (#62)

## Metadata
- **Type:** Feature
- **Appetite:** 2 days
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** no (opt-in)

## Problem
Firestore applies a write to the local cache immediately, but the write's Future resolves
only when the server acknowledges it. Offline, `await collection.update(...)` never returns,
so UIs hang (#62, open since 2022).

## Shaping
- An opt-in write mode that resolves on local apply
  (`Firefuel.initialize(writeAcknowledgement: WriteAck.local)`, or per call). firefuel starts
  the write, returns right away, and routes a later server rejection (for example security
  rules) to `FirefuelObserver.onFailure` (09). Server acknowledgement stays the default.
- `Firefuel.waitForPendingWrites()`, plus `hasPendingWrites` on metadata streams (05), for
  callers that want to show sync state.

## How it fails
- A local-mode `Right` means *applied locally*, not *accepted*. A rejected write rolls back
  locally and listeners see it revert. The docs have to say this plainly.
- On web without persistence, writes made offline are lost when the page reloads.
- Depends on 09. Without an observer, a late failure would be an uncaught async error.

## Outcome (2026-09-23)
- `WriteAcknowledgement.server` (the default, unchanged) and `.local`, set with
  `Firefuel.initialize(writeAcknowledgement:)` or per collection by overriding the
  `writeAcknowledgement` getter.
- In local mode every `FirefuelCollection` write is queued and returns immediately, and a later
  rejection goes to `Firefuel.observer`. `create` now uses `doc()` plus `set()`, so its id exists
  without waiting for the server.
- `Firefuel.waitForPendingWrites()` passes through.
- **Not covered:** `FirefuelBatch`, `Firefuel.batch()` and transactions keep their own
  commit semantics. A batch commit is one atomic request, and a transaction needs the server.
- **Not verified offline.** fake_cloud_firestore can't go offline. The tests prove that local mode
  returns before a server-side rejection and reports it. They don't prove the platform queues
  offline writes (that's Firestore's documented behaviour). Check on a device, airplane mode on,
  before advertising #62 as fixed.
