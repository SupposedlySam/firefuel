# Pass-through inventory

Every public `cloud_firestore` capability is either **exposed** through firefuel, **planned**
(the pitch is named), or **declined** with a reason. Keep this table true: a capability
missing from it is one nobody decided about.

Audited against `cloud_firestore` **6.10.0** on 2026-09-23.

| Capability | cloud_firestore | firefuel | Status |
|---|---|---|---|
| Typed converters | `withConverter` | `FirefuelCollection.fromFirestore/toFirestore` | exposed |
| Create (auto id / by id) | `add`, `doc(id).set` | `create`, `createById`, `generateDocId` | exposed |
| Read one / all / many | `doc.get`, `get` | `read`, `readAll`, `readMany`, `whereById` | exposed |
| Read source | `GetOptions(source:)` | `getOptions:` on reads | exposed |
| Server timestamp behaviour | `GetOptions(serverTimestampBehavior:)` | through `getOptions:` | exposed (reads only) |
| Listen | `snapshots()` | `stream*` | exposed |
| Listen metadata | `includeMetadataChanges`, `SnapshotMetadata` | — | planned: 05 |
| Listen source | `ListenSource.cache` | — | planned: 05 |
| Document changes | `docChanges` | `streamChanges` | exposed (types dropped) |
| Equality/range/in/array filters | `where(...)` | `Clause` | exposed. `arrayContainsAny` was dropped silently (02) |
| Range filters on several fields | server feature, 2024 | refused by firefuel | fix: 02 |
| OR / AND composite filters | `Filter.or`, `Filter.and` | — | planned: 08 |
| Order | `orderBy` | `OrderBy` | exposed (direction bug, 02) |
| Limit | `limit` | `limit:` | exposed |
| Limit to last | `limitToLast` | — | planned: 08 |
| Cursors | `startAt/After`, `endAt/Before` (+ `Document`) | `startAfterDocument` inside `paginate` only | planned: 08 |
| Count | `count()` | `countAll`, `countWhere` | exposed |
| Sum / average | `aggregate(sum, average)` | `sum*`, `average*` | exposed |
| Several aggregations in one query | `aggregate(a, b, c, ...)` | — | planned: 08 |
| Update fields | `update(map)` | `updateFields` | exposed |
| Merge set | `set(..., SetOptions(merge:))` | `updateOrCreate` | exposed |
| `mergeFields` | `SetOptions(mergeFields:)` | — | declined: `replaceFields` covers the use |
| FieldValue.arrayUnion/Remove | ✓ | `arrayUnion`, `arrayRemove` | exposed |
| FieldValue.serverTimestamp | ✓ | `serverTimestamp` (update only) | create-time: 04 |
| FieldValue.increment | ✓ | re-exported `FieldValue` only | planned: 04 |
| FieldValue.delete | ✓ | re-exported `FieldValue` only | planned: 04 |
| Batched writes | `WriteBatch` | `FirefuelBatch` | exposed (off-by-one, #43: 02) |
| Transactions | `runTransaction` | — | planned: 07 |
| Collection groups | `collectionGroup` | — | planned: 06 |
| Named databases | `instanceFor(databaseId:)` | `Firefuel.initialize(instance)` | broken after switch: 03 |
| Emulator, settings, persistence | `useFirestoreEmulator`, `settings` | app configures the instance | declined: app setup, not the data layer |
| Network control | `enableNetwork`, `disableNetwork` | `Firefuel.firestore` | declined: instance-level, reachable as is |
| Pending writes | `waitForPendingWrites`, `snapshotsInSync` | `Firefuel.firestore` | declined for now; 05 exposes `hasPendingWrites` per stream |
| Bundles / named queries | `loadBundle`, `namedQueryGet` | — | declined: no consumer, and bundles are built server-side |
| Persistent cache indexes | `persistentCacheIndexManager` | — | declined: instance-level tuning |
| Vector values | `VectorValue` | passes through `toFirestore` | exposed implicitly |
| Pipelines (incl. `findNearest`, search) | `firestore.pipeline()` | — | declined: Enterprise edition only, a separate query model, no consumer. Revisit when a consumer asks. |
