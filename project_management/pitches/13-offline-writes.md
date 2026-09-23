# Writes that don't hang offline (#62)

## Metadata
- **Type:** Feature
- **Appetite:** 2 days
- **Status:** Pitch
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
