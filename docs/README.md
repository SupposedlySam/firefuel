# Firefuel

Firefuel is a typed, testable data layer for Flutter apps that use [Cloud Firestore](https://firebase.google.com/docs/firestore).

You describe each collection once: its path, and how a document turns into your model and back. Firefuel then gives you every read, query, listen and write as a typed method:

```dart
class NoteCollection extends FirefuelCollection<Note> {
  NoteCollection() : super('notes');

  @override
  Note? fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, _) {
    final data = snapshot.data();
    return data == null ? null : Note.fromJson(data, snapshot.id);
  }

  @override
  Map<String, Object?> toFirestore(Note? note, _) => note?.toJson() ?? {};
}

final notes = NoteCollection();

final pinned = await notes.where([Clause(Note.fieldPinned, isEqualTo: true)]);
final live = notes.streamAll();
await notes.increment(docId: id, field: Note.fieldViews, by: 1);
```

Wrap a collection in a `FirefuelRepository` and each of those methods returns `Either<Failure, T>` instead of throwing. Your UI then handles failure explicitly, in the same way everywhere.

## What you get

- **Typed CRUD**: create, read, update, replace and delete, plus `readMany`, `readOrCreate` and `updateOrCreate`.
- **Queries as values**: `Clause`s (with `Clause.or` and `Clause.and`), `OrderBy`, limits, `limitToLast` and cursors. Build them into one `FirefuelQuery` you can read, stream, count, aggregate or paginate.
- **Live data with metadata**: every read has a stream form, and `snapshots` also tells you what changed, whether the data came from the cache, and which writes are still pending.
- **Server values**: `FieldUpdate.increment`, array union/remove, delete, and `ServerTimestamp`. You can return a `ServerTimestamp` straight from a model's `toJson`.
- **Collection groups, transactions and atomic batches**, all typed.
- **Offline-friendly writes**: optionally, writes complete once they're queued locally instead of hanging until the server answers.
- **One place for failures**: a `FirefuelObserver` hears every failure firefuel handles.

Start with [Getting Started](gettingstarted.md). If you're upgrading, read [Migrating to 0.5](migrating.md).

## Packages

| Package | What it is |
| -- | -- |
| [firefuel](https://pub.dev/packages/firefuel) | The library. Depends on Flutter and `cloud_firestore`. |
| [firefuel_core](https://pub.dev/packages/firefuel_core) | `Serializable`, `DocumentId`, `Failure`, `Either` and `FieldUpdate`, with no Flutter or Firestore dependency. Use it in model packages shared with a server or a CLI. |
