# Firefuel API Guide

This guide shows the main Firefuel APIs by use case. Collections return raw typed values, while repositories wrap the same calls in `Either<Failure, T>` so callers handle failures explicitly.

```dart
final noteCollection = NoteCollection();
final noteRepository = NoteRepository(collection: noteCollection);
```

## Initialization

Call `Firefuel.initialize` before creating collections. You can optionally pass an `env` prefix to separate collection names by environment.

```dart
Firefuel.initialize(FirebaseFirestore.instance);

Firefuel.initialize(
  FirebaseFirestore.instance,
  env: 'dev',
);
```

Use `Firefuel.reset` in tests when you need to clear the configured Firestore instance.

```dart
tearDown(Firefuel.reset);
```

## Creating Documents

Use `create` when Firestore should generate the document id, or `createById` when your app already knows the id.

```dart
final docId = await noteCollection.create(note);
final draftDocId = noteCollection.generateDocId();

await noteCollection.createById(
  docId: draftDocId,
  value: note,
);
```

## Reading Documents

Use `read` for one document, `readAll` for the whole collection, and `readOrCreate` when your app needs a default document to exist before continuing.

```dart
final maybeNote = await noteCollection.read(DocumentId('welcome-note'));
final notes = await noteCollection.readAll();

final settings = await settingsCollection.readOrCreate(
  createValue: const Settings.defaults(),
  docId: DocumentId('current-user'),
);
```

Use `readMany` when you already have a list of document ids. Results keep the same order as the ids you pass in, and missing documents are returned as `null`.

```dart
final notes = await noteCollection.readMany([
  DocumentId('first-note'),
  DocumentId('second-note'),
]);

final noteById = await noteCollection.whereById(
  DocumentId('welcome-note'),
);
```

## Streaming Data

Use `stream` for one document and `streamAll` for a live collection.

```dart
final noteStream = noteCollection.stream(DocumentId('welcome-note'));
final notesStream = noteCollection.streamAll();
final firstFiveNotesStream = noteCollection.streamLimited(5);
```

Use `streamMany` when you need a live view of a known set of documents.

```dart
final selectedNotesStream = noteCollection.streamMany([
  DocumentId('first-note'),
  DocumentId('second-note'),
]);
```

Use `streamChanges` when you only want documents changed by each snapshot. Removed documents are excluded by default.

```dart
final changedNotesStream = noteCollection.streamChanges();

final changedAndRemovedNotesStream = noteCollection.streamChanges(
  includeRemoved: true,
);
```

## Querying and Ordering

Use `where` for one-time filtered reads and `streamWhere` for live filtered reads.

```dart
final pinnedNotes = await noteCollection.where([
  Clause(Note.fieldPinned, isEqualTo: true),
]);

final pinnedNotesStream = noteCollection.streamWhere([
  Clause(Note.fieldPinned, isEqualTo: true),
]);
```

Use `orderBy` or `streamOrdered` when the sort is the main point of the query.

```dart
final firstFiveNotes = await noteCollection.limit(5);

final newestNotes = await noteCollection.orderBy([
  OrderBy(field: Note.fieldCreatedAt, direction: OrderDirection.desc),
]);

final newestNotesStream = noteCollection.streamOrdered([
  OrderBy(field: Note.fieldCreatedAt, direction: OrderDirection.desc),
]);
```

You can also pass `orderBy` and `limit` to `where` and `streamWhere`.

```dart
final newestPinnedNotes = await noteCollection.where(
  [Clause(Note.fieldPinned, isEqualTo: true)],
  limit: 10,
  orderBy: [
    OrderBy(field: Note.fieldCreatedAt, direction: OrderDirection.desc),
  ],
);
```

## Pagination

Use `paginate` with a `Chunk` when you want to load a collection one page at a time.

```dart
final firstPage = await noteCollection.paginate(
  Chunk(orderBy: [OrderBy(field: Note.fieldCreatedAt)]),
);

final nextPage = await noteCollection.paginate(firstPage);
```

Continue passing the returned `Chunk` back into `paginate` until `chunk.status` is `ChunkStatus.last`.

## Counting and Aggregates

Use `countAll` and `countWhere` to count documents without downloading every document.

```dart
final totalNotes = await noteCollection.countAll();

final pinnedNotes = await noteCollection.countWhere([
  Clause(Note.fieldPinned, isEqualTo: true),
]);
```

Use `sumAll`, `sumWhere`, `averageAll`, and `averageWhere` for numeric Firestore aggregate queries.

```dart
final totalReadingMinutes = await noteCollection.sumAll(
  Note.fieldReadingMinutes,
);

final averagePinnedReadingMinutes = await noteCollection.averageWhere(
  [Clause(Note.fieldPinned, isEqualTo: true)],
  Note.fieldReadingMinutes,
);
```

For live counts, use `streamCountAll` or `streamCountWhere`. These stream documents and count the snapshot size locally because Firestore aggregate streams are not available.

```dart
final livePinnedCount = noteCollection.streamCountWhere([
  Clause(Note.fieldPinned, isEqualTo: true),
]);
```

## Updating Documents

Use `update` to merge an entire model into an existing document.

```dart
await noteCollection.update(
  docId: DocumentId('welcome-note'),
  value: updatedNote,
);
```

Use `updateFields` for small field-only changes.

```dart
await noteCollection.updateFields(
  docId: DocumentId('welcome-note'),
  fields: {Note.fieldPinned: true},
);
```

Use `replace` to overwrite a document with a model, and `replaceFields` to overwrite only fields taken from a model.

```dart
await noteCollection.replace(
  docId: DocumentId('welcome-note'),
  value: replacementNote,
);

await noteCollection.replaceFields(
  docId: DocumentId('welcome-note'),
  fieldPaths: [Note.fieldTitle],
  value: replacementNote,
);
```

Use `updateOrCreate` when you want to merge data into a document and create it if needed.

```dart
await noteCollection.updateOrCreate(
  docId: DocumentId('welcome-note'),
  value: note,
);
```

## Field Transforms

Use `arrayUnion` and `arrayRemove` for Firestore array transforms.

```dart
await noteCollection.arrayUnion(
  docId: DocumentId('welcome-note'),
  field: Note.fieldTags,
  values: ['flutter'],
);

await noteCollection.arrayRemove(
  docId: DocumentId('welcome-note'),
  field: Note.fieldTags,
  values: ['old-tag'],
);
```

Use `serverTimestamp` when Firestore should write the current server time.

```dart
await noteCollection.serverTimestamp(
  docId: DocumentId('welcome-note'),
  field: Note.fieldUpdatedAt,
);
```

Firefuel also re-exports `FieldValue` for custom transforms.

```dart
await noteCollection.updateFields(
  docId: DocumentId('welcome-note'),
  fields: {Note.fieldUpdatedAt: FieldValue.serverTimestamp()},
);
```

## Deleting Documents

Use `delete` to delete one document by id.

```dart
await noteCollection.delete(DocumentId('welcome-note'));
```

!> Firestore does not recursively delete subcollections when you delete a document.

## Batches

Use `FirefuelBatch` when several writes should be committed together. Batch writes support the same create, update, transform, replace, and delete methods as collections.

```dart
final batch = FirefuelBatch(noteCollection);

await batch.create(firstNote);
await batch.updateFields(
  docId: DocumentId('welcome-note'),
  fields: {Note.fieldPinned: true},
);
await batch.arrayUnion(
  docId: DocumentId('welcome-note'),
  field: Note.fieldTags,
  values: ['batched'],
);

await batch.commit();
```

Use `batch.reset()` to discard queued writes and start a new batch without committing.

## Repositories

Repositories expose the same collection methods, but return `Either<Failure, T>` so UI and business logic can handle success and failure in one place.

```dart
final result = await noteRepository.read(DocumentId('welcome-note'));

result.fold(
  (failure) => print(failure.error),
  (note) => print(note),
);
```

Repository streams return `Stream<Either<Failure, T>>`.

```dart
final stream = noteRepository.streamAll();
```

## Quick Feature Map

- Setup: `Firefuel.initialize`, `Firefuel.reset`
- Create: `create`, `createById`, `generateDocId`
- Read: `read`, `readAll`, `readMany`, `readOrCreate`, `whereById`
- Stream: `stream`, `streamAll`, `streamMany`, `streamChanges`
- Query: `where`, `streamWhere`, `orderBy`, `streamOrdered`, `limit`, `streamLimited`
- Pagination: `paginate`, `Chunk`, `ChunkStatus`
- Count: `countAll`, `countWhere`, `streamCountAll`, `streamCountWhere`
- Aggregates: `sumAll`, `sumWhere`, `averageAll`, `averageWhere`
- Update: `update`, `updateFields`, `updateOrCreate`, `replace`, `replaceFields`
- Field transforms: `arrayUnion`, `arrayRemove`, `serverTimestamp`, `FieldValue`
- Delete: `delete`
- Batch writes: `FirefuelBatch`, `commit`, `reset`
- Error handling: `FirefuelRepository`, `Either`, `Failure`
