# Pass-through inventory

Every public `cloud_firestore` capability is either **exposed** through firefuel, **planned**
(the pitch is named), or **declined** with a reason. Keep this table true: a capability
missing from it is one nobody decided about.

Audited against `cloud_firestore` **6.10.0** on 2026-09-23.

| Capability | cloud_firestore | firefuel | Status |
|---|---|---|---|
| Typed converters | `withConverter` | `FirefuelCollection.fromFirestore/toFirestore` | exposed |
| Write acknowledgement | (Futures resolve on server ack) | `WriteAcknowledgement.local` | added (13) |
| Create (auto id / by id) | `add`, `doc(id).set` | `create`, `createById`, `generateDocId` | exposed |
| Read one / all / many | `doc.get`, `get` | `read`, `readAll`, `readMany`, `whereById` | exposed |
| Read source | `GetOptions(source:)` | `getOptions:` on reads | exposed |
| Server timestamp behaviour | `GetOptions(serverTimestampBehavior:)` | through `getOptions:` | exposed (reads only) |
| Listen | `snapshots()` | `stream*` | exposed |
| Listen metadata | `includeMetadataChanges`, `SnapshotMetadata` | `snapshots`, `docSnapshots`, `ListenOptions` | exposed (05) |
| Listen source | `ListenSource.cache` | `ListenOptions.source` | exposed (05) |
| Document changes | `docChanges` | `streamChanges`, `FirefuelQuerySnapshot.changes` | exposed |
| Equality/range/in/array filters | `where(...)` | `Clause` | exposed (`arrayContainsAny` fixed in 02) |
| Range filters on several fields | server feature, 2024 | `Clause` | exposed (02) |
| OR / AND composite filters | `Filter.or`, `Filter.and` | `Clause.or`, `Clause.and` | exposed (08) |
| Order | `orderBy` | `OrderBy` | exposed (direction fixed in 02) |
| Limit | `limit` | `limit:` | exposed |
| Limit to last | `limitToLast` | `FirefuelQuery.limitToLast` | exposed (12) |
| Cursors | `startAt/After`, `endAt/Before` (+ `Document`) | `StartCursor`, `EndCursor` (values); document cursors inside `paginate` | exposed (12) |
| Count | `count()` | `countAll`, `countWhere` | exposed |
| Sum / average | `aggregate(sum, average)` | `sum*`, `average*` | exposed |
| Several aggregations in one query | `aggregate(a, b, c, ...)` | `aggregate(query, count:, sums:, averages:)` | exposed (08) |
| Update fields | `update(map)` | `updateFields` | exposed |
| Merge set | `set(..., SetOptions(merge:))` | `updateOrCreate` | exposed |
| `mergeFields` | `SetOptions(mergeFields:)` | — | declined: `replaceFields` covers the use |
| FieldValue.arrayUnion/Remove | ✓ | `arrayUnion`, `arrayRemove` | exposed |
| FieldValue.serverTimestamp | ✓ | `serverTimestamp`, `ServerTimestamp` on every write | exposed (04) |
| FieldValue.increment | ✓ | `increment`, `FieldUpdate.increment` | exposed (04) |
| FieldValue.delete | ✓ | `deleteField`, `FieldUpdate.delete` | exposed (04) |
| Batched writes | `WriteBatch` | `Firefuel.batch()` (atomic, multi-collection), `FirefuelBatch` (bulk) | exposed (07) |
| Transactions | `runTransaction` | `Firefuel.runTransaction`, `TransactionScope` | exposed (07) |
| Collection groups | `collectionGroup` | `FirefuelCollectionGroup` | exposed (06) |
| Named databases | `instanceFor(databaseId:)` | `Firefuel.initialize(instance)`, `FirefuelCollection(firestore:)` | exposed (03) |
| Emulator, settings, persistence | `useFirestoreEmulator`, `settings` | app configures the instance | declined: app setup, not the data layer |
| Network control | `enableNetwork`, `disableNetwork` | `Firefuel.firestore` | declined: instance-level, reachable as is |
| Pending writes | `waitForPendingWrites`, `snapshotsInSync` | `Firefuel.waitForPendingWrites`, `hasPendingWrites` on snapshots | exposed (13); `snapshotsInSync` declined, instance-level |
| Bundles / named queries | `loadBundle`, `namedQueryGet` | — | declined: no consumer, and bundles are built server-side |
| Persistent cache indexes | `persistentCacheIndexManager` | — | declined: instance-level tuning |
| Vector values | `VectorValue` | passes through `toFirestore` | exposed implicitly |
| Pipelines (incl. `findNearest`, search) | `firestore.pipeline()` | — | declined: Enterprise edition only, a separate query model, no consumer. Revisit when a consumer asks. |
