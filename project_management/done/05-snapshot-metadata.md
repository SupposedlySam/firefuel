# Streams that say where the data came from

## Metadata
- **Type:** Feature
- **Appetite:** 2 days
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** no

## Problem
Every firefuel stream throws away `SnapshotMetadata`. A UI cannot tell "this is cached" from
"the server confirmed this", or "my write is still pending" from "my write landed". flyby
shows a *syncing* pill and reads `isFromCache` from a raw listener. Issue #62 is the same gap
from the write side: while offline, awaiting a write never resolves, and firefuel offers
nothing to observe pending writes instead of awaiting them.

## Evidence
flyby audit A (`message_reaction_remote_data_source.dart:39-49`), issue #62.

## Shaping
- `FirefuelSnapshot<R>` holds `data`, `isFromCache`, `hasPendingWrites`.
- The existing streams (`streamAll`, `streamWhere`, `stream`, …) stay as they are. Callers opt
  into metadata through a `ListenOptions` value carrying `includeMetadataChanges` and
  `ListenSource`, passed to a small set of `…Snapshots` methods, or through one generic
  `snapshots(query)` entry point. Pick one with the reviewers; don't double the API surface.
- `ListenSource.cache` is passed through, since cloud_firestore exposes it and firefuel doesn't.

## Out of scope
- Automatic offline write queues. Firestore already queues writes; the fix is to make its
  state visible.

## flyby's answer (2026-09-23)
**Highest value.** flyby just built a *syncing* pill and had to give up on `isFromCache`,
because `streamChanges` drops metadata. Wanted shape: `includeMetadataChanges` returning
`Stream<FirefuelSnapshot<List<T>>>` with `.value`, `.isFromCache` and `.hasPendingWrites`, on
`streamWhere`, `streamChanges` and `streamAll`. The existing List-returning methods stay as they are.

## Outcome (2026-09-23)
- Two entry points ([DESIGN.md](../DESIGN.md) D3): `snapshots(FirefuelQuery, {ListenOptions})`
  returns `FirefuelQuerySnapshot<T>`, and `docSnapshots(DocumentId, {ListenOptions})` returns
  `FirefuelSnapshot<T?>`. Both are on collections and repositories (via the new `QueryListen`
  and `DocListen` rules), and collection groups get `snapshots` through the mixin.
- `FirefuelQuerySnapshot` carries `value`, `docs` (id, path, pending-write state per doc,
  `ancestorId()`), `changes` (type, doc, indexes), `isFromCache` and `hasPendingWrites`. That
  covers flyby's syncing pill and the metadata its `streamChanges` usage was losing.
- `ListenOptions` passes `includeMetadataChanges` and `ListenSource` through. A test on a
  mocked base query verifies they reach Firestore; the fake ignores both.
- **Shape changed from flyby's ask:** there's no flag on `streamWhere`/`streamAll`/`streamChanges`,
  because a flag can't change a stream's element type. `snapshots(FirefuelQuery(clauses: ...))`
  is the metadata form of each of those.
- **Not tested for real:** `isFromCache` and `hasPendingWrites` as the platform produces them.
  fake_cloud_firestore always reports server-confirmed data, so the mapping is tested on mocked
  snapshots. Verify on a device or the emulator before relying on the exact timing of
  metadata-only events.
