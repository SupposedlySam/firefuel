# Firefuel API Guide

This guide walks through Firefuel's API by use case. Collections return plain typed values and throw on failure. Repositories expose the same methods but return `Either<Failure, T>`, so callers have to handle failure.

```dart
final notes = NoteCollection();
final noteRepository = NoteRepository(collection: notes);
```

## Initialization

Call `Firefuel.initialize` once, before using any collection.

```dart
Firefuel.initialize(FirebaseFirestore.instance);

Firefuel.initialize(
  FirebaseFirestore.instance,
  env: 'dev', // prefixes top-level collection names: dev-notes
  observer: const CrashReportingObserver(), // see "Observing failures"
  writeAcknowledgement: WriteAcknowledgement.local, // see "Writing while offline"
);
```

Collections look up `Firefuel.firestore` on every call, so calling `initialize` again (for example to switch to a named database) moves them all over. To pin a collection to one instance, pass it:

```dart
class AuditCollection extends FirefuelCollection<AuditEntry> {
  AuditCollection(FirebaseFirestore auditDb) : super('audit', firestore: auditDb);
  // ...
}
```

In tests, `tearDown(Firefuel.reset)` clears the configuration.

## Creating documents

Use `create` to let Firestore generate the id, or `createById` when you already know it.

```dart
final docId = await notes.create(note);

final draftId = notes.generateDocId();
await notes.createById(docId: draftId, value: note);
```

## Reading documents

```dart
final maybeNote = await notes.read(DocumentId('welcome'));
final all = await notes.readAll();

final settings = await settingsCollection.readOrCreate(
  docId: DocumentId('current-user'),
  createValue: const Settings.defaults(),
);
```

`readMany` returns documents in the order you asked for them, with `null` for any that are missing.

```dart
final selected = await notes.readMany([DocumentId('a'), DocumentId('b')]);
```

Reads take `GetOptions`, for example to read only from the cache:

```dart
final cached = await notes.read(
  id,
  getOptions: const GetOptions(source: Source.cache),
);
```

## Streaming data

Each read has a stream form that refreshes as data changes.

```dart
notes.stream(DocumentId('welcome'));
notes.streamAll();
notes.streamLimited(5);
notes.streamMany([DocumentId('a'), DocumentId('b')]);
notes.streamChanges(); // only documents changed by each snapshot
```

## Querying

`where` and `streamWhere` take a list of `Clause`s, and a document must match all of them. You can also pass an order and a limit.

```dart
final pinned = await notes.where(
  [Clause(Note.fieldPinned, isEqualTo: true)],
  orderBy: [OrderBy(field: Note.fieldCreatedAt, direction: OrderDirection.newestToOldest)],
  limit: 10,
);
```

A `Clause` takes exactly one operator: `isEqualTo`, `isNotEqualTo`, `isLessThan`, `isLessThanOrEqualTo`, `isGreaterThan`, `isGreaterThanOrEqualTo`, `arrayContains`, `arrayContainsAny`, `whereIn`, `whereNotIn` or `isNull`.

Range filters can be on several fields (Firestore allows up to 10). When a query has a range filter, Firestore requires the first `orderBy` to be on a range field. Firefuel moves or adds that ordering for you.

### OR and AND

`Clause.or` matches documents that meet any of its clauses. `Clause.and` is only needed inside an `or`, because the top-level list is already an AND.

```dart
final flagged = await notes.where([
  Clause(Note.fieldArchived, isEqualTo: false),
  Clause.or([
    Clause(Note.fieldPinned, isEqualTo: true),
    Clause.and([
      Clause(Note.fieldViews, isGreaterThan: 100),
      Clause(Note.fieldAuthor, isEqualTo: me),
    ]),
  ]),
]);
```

### Ordering

`OrderDirection` has plain names (`asc`, `desc`) and descriptive aliases: `aToZ`, `zToA`, `smallestToLargest`, `largestToSmallest`, `oldestToNewest`, `newestToOldest`, `falseToTrue`, `trueToFalse`.

```dart
final newestFirst = await notes.orderBy([
  OrderBy(field: Note.fieldCreatedAt, direction: OrderDirection.newestToOldest),
]);

final byId = await notes.orderBy([const OrderBy.docId()]);
```

### Queries as values

`FirefuelQuery` describes a whole read: clauses, order, `limit` or `limitToLast`, and start and end cursors. Every query method builds one internally. Build your own when the shorthands can't express what you need.

```dart
final lastFive = await notes.query(
  FirefuelQuery(
    orderBy: [OrderBy(field: Note.fieldCreatedAt)],
    limitToLast: 5,
  ),
);

final february = notes.streamQuery(
  FirefuelQuery(
    orderBy: [OrderBy(field: Note.fieldCreatedAt)],
    start: StartCursor.at([DateTime(2026, 2)]),
    end: EndCursor.before([DateTime(2026, 3)]),
  ),
);
```

Cursor values line up with the `orderBy` fields, first to first. `limitToLast` and cursors require an `orderBy`, and firefuel throws `MissingValueException` if it's missing. A query is immutable; use `copyWith` to derive variations.

## Pagination

`paginate` reads one page at a time. Pass back the `Chunk` it returns until its `status` is `ChunkStatus.last`.

```dart
var page = Chunk<Note>(
  orderBy: [OrderBy(field: Note.fieldCreatedAt, direction: OrderDirection.newestToOldest)],
  clauses: [Clause(Note.fieldArchived, isEqualTo: false)],
  limit: 20,
);

page = await notes.paginate(page); // first page
page = await notes.paginate(page); // next page, same filters and size
```

To paginate a `FirefuelQuery`, use `Chunk.query(FirefuelQuery(...))`.

## Counting and aggregates

Counts and aggregates run on the server, so only the numbers are transferred.

```dart
final total = await notes.countAll();
final pinned = await notes.countWhere([Clause(Note.fieldPinned, isEqualTo: true)]);

final minutes = await notes.sumAll(Note.fieldReadingMinutes);
final average = await notes.averageWhere(
  [Clause(Note.fieldPinned, isEqualTo: true)],
  Note.fieldReadingMinutes,
);
```

`aggregate` does several at once, in one request:

```dart
final stats = await notes.aggregate(
  FirefuelQuery(clauses: [Clause(Note.fieldPinned, isEqualTo: true)]),
  count: true,
  sums: [Note.fieldReadingMinutes],
  averages: [Note.fieldReadingMinutes],
);

print('${stats.count} notes, ${stats.sums[Note.fieldReadingMinutes]} minutes');
```

`streamCountAll` and `streamCountWhere` give live counts. Firestore can't listen to an aggregation, so these stream the matching documents and count them, and each matching document is a billed read.

## Listening with metadata

`snapshots` and `docSnapshots` report not just the data, but where it came from.

```dart
notes
    .snapshots(
      FirefuelQuery(clauses: [Clause(Note.fieldPinned, isEqualTo: true)]),
      options: const ListenOptions(includeMetadataChanges: true),
    )
    .listen((snapshot) {
      snapshot.value; // List<Note>
      snapshot.isFromCache; // served from the local cache?
      snapshot.hasPendingWrites; // includes writes the server hasn't confirmed?
      for (final change in snapshot.changes) {
        change.type; // added, modified or removed
        change.doc.id;
      }
    });

final noteWithMetadata = notes.docSnapshots(DocumentId('welcome'));
```

Pass `includeMetadataChanges: true` to also hear when *only* the metadata changes, for example when a pending write is confirmed. A "syncing…" indicator needs that. `ListenOptions(source: ListenSource.cache)` listens to the cache only.

Each `snapshot.docs` entry carries the document's `id` and `path`. `doc.ancestorId('conversations')` returns the id of the ancestor document in the `conversations` collection.

## Collection groups

A collection group reads every subcollection with a given id, wherever it lives. Implement `fromFirestore` and you get the full read surface: queries, counts, aggregates, pagination, streams and snapshots.

```dart
class ReactionGroup extends FirefuelCollectionGroup<Reaction> {
  ReactionGroup() : super('reactions');

  @override
  Reaction? fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
      Reaction.fromJson(snapshot.data()!);
}

final reactions = await ReactionGroup().snapshots(
  FirefuelQuery(clauses: [Clause(Reaction.fieldConversationId, isEqualTo: id)]),
).first;

for (final doc in reactions.docs) {
  final messageId = doc.ancestorId('messages');
}
```

Groups are read-only. Write through the `FirefuelCollection` for the document's parent. Filtered group queries usually need a collection-group index; Firestore's error message links to the console page that creates it. `Firefuel.env` prefixes only top-level collections, so a group spans every environment that shares a database.

To get `Either` results from a group, extend `FirefuelQueryRepository`:

```dart
class ReactionRepository extends FirefuelQueryRepository<Reaction> {
  ReactionRepository(ReactionGroup group) : super(source: group);
}
```

## Updating documents

```dart
await notes.update(docId: id, value: updatedNote); // merges into an existing document
await notes.updateOrCreate(docId: id, value: note); // merges, creating the document if needed
await notes.updateFields(docId: id, fields: {Note.fieldPinned: true});
```

### Replace

`replace` overwrites an existing document with your model. `replaceFields` overwrites only the listed fields.

```dart
await notes.replace(docId: id, value: replacement);
await notes.replaceFields(docId: id, value: replacement, fieldPaths: [Note.fieldTitle]);
```

`replace` fails with `not-found` if the document doesn't exist. Firestore checks that when the write lands, so `replace` is atomic, costs no read, and works offline.

### Field updates

A `FieldUpdate` is a value the server computes. You can use one anywhere a field value is written, and mix several with plain values in a single, atomic `updateFields`:

```dart
await users.updateFields(
  docId: userId,
  fields: {
    User.fieldTokens: FieldUpdate.arrayUnion([token]),
    User.fieldLoginCount: const FieldUpdate.increment(1),
    User.fieldLastSeen: const FieldUpdate.serverTimestamp(),
    User.fieldLegacyFlag: const FieldUpdate.delete(),
    User.fieldSupportsReactions: true,
  },
);
```

There are shorthands for the common single-field cases: `increment`, `arrayUnion`, `arrayRemove`, `serverTimestamp` and `deleteField`.

```dart
await notes.increment(docId: id, field: Note.fieldViews, by: 1);
await notes.arrayUnion(docId: id, field: Note.fieldTags, values: ['flutter']);
await notes.deleteField(docId: id, field: Note.fieldDraft);
```

### Server timestamps from your model

`FieldUpdate` lives in firefuel_core, so your models can use it without depending on Flutter or Firestore. Return a `ServerTimestamp` from `toJson` for a field the server should stamp:

```dart
Map<String, dynamic> toJson() => {
  fieldText: text,
  fieldCreatedAt: createdAt ?? const ServerTimestamp(),
};
```

Firefuel converts it on every write path: create, update, replace, batches and transactions. Until the server confirms the write, a read from the local cache sees `null` for that field. To get the local clock's estimate instead:

```dart
final note = await notes.read(
  id,
  getOptions: const GetOptions(serverTimestampBehavior: ServerTimestampBehavior.estimate),
);
```

## Deleting documents

```dart
await notes.delete(DocumentId('welcome'));
```

!> Firestore doesn't delete subcollections when you delete their parent document.

## Transactions

A transaction reads documents and then writes based on what it read. If any of those documents changes before the transaction commits, Firestore runs it again. Scope the transaction to each collection with `of`:

```dart
await Firefuel.runTransaction((transaction) async {
  final accounts = transaction.of(accountCollection);
  final from = await accounts.read(fromId);
  final to = await accounts.read(toId);

  accounts
    ..update(docId: fromId, value: from!.withdraw(amount))
    ..update(docId: toId, value: to!.deposit(amount));
});
```

- Do all reads before the first write. Reading after a write throws `ReadAfterWriteException`.
- `transaction.of(collection).readOrCreate(...)` is the atomic version of `readOrCreate`.
- The handler may run more than once, so keep side effects out of it.
- Transactions need the server, so they fail while offline.

## Batches

`Firefuel.batch()` collects writes across collections and commits them atomically: all land, or none do.

```dart
final batch = Firefuel.batch();
batch.of(notes).createById(docId: id, value: note);
batch.of(authors).updateFields(
  docId: authorId,
  fields: {Author.fieldNoteCount: const FieldUpdate.increment(1)},
);
await batch.commit();
```

`FirefuelBatch(collection)` is the older, single-collection bulk writer. It commits automatically every 500 writes, so a large import isn't atomic as a whole. Use it when you have more writes than fit in one request.

## Repositories

Repositories expose the same methods, but return `Either<Failure, T>`:

```dart
final result = await noteRepository.read(DocumentId('welcome'));

final title = switch (result) {
  Left(:final value) => 'Could not load: ${value.error}',
  Right(:final value) => value?.title ?? 'Missing',
};
```

Streams return `Stream<Either<Failure, T>>`. Use `guard` and `guardStream` (from `FirefuelFetchMixin`) to give your own repository methods the same behaviour:

```dart
Future<Either<Failure, void>> transfer(DocumentId from, DocumentId to, int amount) {
  return guard(() => Firefuel.runTransaction((transaction) async { /* ... */ }));
}
```

## Observing failures

Every failure a repository returns (or that `guard` catches) is reported to `Firefuel.observer`. By default it's logged through `dart:developer`, which shows in the debug console and DevTools. Send failures somewhere else by passing your own observer:

```dart
class CrashReportingObserver extends FirefuelObserver {
  const CrashReportingObserver();

  @override
  void onFailure(Failure failure) {
    FirebaseCrashlytics.instance.recordError(failure.error, failure.stackTrace);
  }
}
```

`SilentFirefuelObserver` ignores everything.

## Writing while offline

Firestore applies a write to the local cache immediately, but the write's `Future` only completes when the server responds. Offline, `await notes.update(...)` hangs until the connection returns, even though every listener already shows the change.

With `WriteAcknowledgement.local`, collection writes complete as soon as they're queued:

```dart
Firefuel.initialize(
  FirebaseFirestore.instance,
  writeAcknowledgement: WriteAcknowledgement.local,
);
```

In this mode a successful write means "applied locally", not "accepted by the server". If the server later rejects the write (security rules, or a document that no longer exists), the cache rolls it back, listeners see it revert, and the failure goes to your observer. To decide per collection, override `writeAcknowledgement` on that collection. `Firefuel.waitForPendingWrites()` completes once everything queued has reached the server.

Transactions and batches aren't affected: a batch commits in one request, and a transaction needs the server.

## Quick feature map

- Setup: `Firefuel.initialize`, `Firefuel.reset`, `Firefuel.waitForPendingWrites`
- Create: `create`, `createById`, `generateDocId`
- Read: `read`, `readAll`, `readMany`, `readOrCreate`, `whereById`
- Stream: `stream`, `streamAll`, `streamMany`, `streamChanges`, `streamQuery`
- Metadata: `snapshots`, `docSnapshots`, `ListenOptions`
- Query: `where`, `streamWhere`, `orderBy`, `streamOrdered`, `limit`, `streamLimited`, `query`, `FirefuelQuery`, `Clause.or`, `Clause.and`, `StartCursor`, `EndCursor`
- Pagination: `paginate`, `Chunk`, `Chunk.query`, `ChunkStatus`
- Count and aggregate: `countAll`, `countWhere`, `sumAll`, `sumWhere`, `averageAll`, `averageWhere`, `aggregate`, `streamCountAll`, `streamCountWhere`
- Update: `update`, `updateFields`, `updateOrCreate`, `replace`, `replaceFields`
- Field updates: `FieldUpdate`, `ServerTimestamp`, `increment`, `arrayUnion`, `arrayRemove`, `serverTimestamp`, `deleteField`
- Delete: `delete`
- Groups: `FirefuelCollectionGroup`, `FirefuelQueryRepository`
- Transactions and batches: `Firefuel.runTransaction`, `Firefuel.batch`, `FirefuelBatch`
- Errors: `FirefuelRepository`, `Either`, `Failure`, `FirefuelObserver`, `WriteAcknowledgement`
