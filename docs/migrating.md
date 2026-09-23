# Migrating to 0.5

firefuel 0.5 and firefuel_core 0.2 fix several methods that didn't do what their names said, drop two dependencies, and add a lot of Firestore that used to be out of reach. Most apps need only the changes in **Required changes**. Then check **Behaviour changes** for code that relied on the old behaviour.

## Required changes

### Dart 3.10 and Flutter 3.38

```yaml
environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"
```

firefuel builds against `cloud_firestore` ^6.10.

### `Either` comes from firefuel, not dartz

firefuel used to re-export `Either` from `package:dartz`, which hasn't been released since 2021. `Either`, `Left`, `Right`, `left()` and `right()` now live in firefuel_core, and `package:firefuel/firefuel.dart` exports them as before.

If you import `Either` only through firefuel, nothing changes. If you import dartz directly for firefuel results, change the import:

```dart
// Before
import 'package:dartz/dartz.dart';

// After
import 'package:firefuel/firefuel.dart'; // or package:firefuel_core/firefuel_core.dart
```

`fold`, `map`, `isLeft`, `isRight`, `getOrElse`, `swap` and the `getRight`/`getLeft`/`…OrElseNull` extensions are unchanged. New: `leftMap`, `flatMap`, and exhaustive pattern matching:

```dart
final label = switch (await repository.read(id)) {
  Left(:final value) => 'Failed: ${value.error}',
  Right(:final value) => value?.title ?? 'Missing',
};
```

Other dartz methods (`bind`, `toOption`, …) aren't provided.

### `countAll` / `countWhere` take `source:`

They accepted `getOptions:` and ignored it. They now take `AggregateSource? source`, like `sumAll` and `averageAll`.

### `replace` no longer takes `getOptions:`

See [replace](#replace-fails-for-a-missing-document) below.

### `Clause` is sealed

`Clause(field, isEqualTo: …)` works as before. If you read a clause's properties (`clause.field`, `clause.isEqualTo`) through a variable typed `Clause`, match on `FieldClause` first. A clause can now also be a `Clause.or` / `Clause.and` group.

## Behaviour changes

### `newestToOldest` and `oldestToNewest` were reversed

`OrderDirection.newestToOldest` sorted ascending and `oldestToNewest` sorted descending. "Newest" means the largest timestamp, so they now sort `desc` and `asc`. If your code compensated for the old order, remove the workaround.

`OrderBy.docId(OrderDirection.zToA)` (and other descending aliases) also sorted ascending, and now sorts descending.

### `paginate` kept only the first page's filters

Pages after the first ignored the `Chunk`'s `clauses` and fell back to 25 documents. Every page now uses the same query. If you added filtering on the client to make up for it, you can remove it.

### `Clause(arrayContainsAny: …)` now filters

It was never passed to Firestore, so the query ran unfiltered.

### Range filters on several fields are allowed

firefuel threw `MoreThanOneFieldInRangeClauseException`. Firestore has supported range filters on up to 10 fields since 2024, so firefuel now sends the query. The exception is deprecated and no longer thrown. Firestore may ask for a composite index.

### `replace` fails for a missing document

`replace` used to read the document and then overwrite it, silently doing nothing if it didn't exist. It's now a single `update` of the whole document:

- A missing document is an error: `not-found` from a collection, a `Left` from a repository.
- It's atomic, costs no read, and works offline.
- Inside a `FirefuelBatch`, it can replace a document created earlier in the same batch. That combination used to be dropped silently (#43).

Fields stored in the document but absent from your `toFirestore` output are left in place.

### `update` and `replaceFields` serialize through `toFirestore`

They used `value.toJson()`, while `create` and `updateOrCreate` used your collection's `toFirestore`. Every write now goes through `toFirestore`. This only matters if the two differ.

### Failures are no longer printed

Constructing a `FirefuelFailure` printed it to stdout, and `guard` printed every `FormatException`. Failures now go to `Firefuel.observer`, which logs through `dart:developer` by default. Pass your own [observer](firefuelapi.md#observing-failures) to route them elsewhere, or `SilentFirefuelObserver` to ignore them.

### `Firefuel.firestore` throws a `StateError` before `initialize`

It was an `assert`, which release builds skip.

### Collections follow `Firefuel.initialize`

A collection captured `Firefuel.firestore` when it was constructed, so after re-initializing, existing collections kept using the old instance. They now resolve it on every call. To keep a collection on one instance, pass it: `super('notes', firestore: instance)`.

### `streamOrdered([])` throws

As its documentation always said, it now throws `MissingValueException`.

### `FirefuelBatch` counts correctly

Auto-commit happened one op early, and `totalTransactionsCommitted` over-counted. Both are fixed. For atomic writes across collections, prefer the new [`Firefuel.batch()`](firefuelapi.md#batches).

## Removed

- The `dartz` and `universal_io` dependencies.
- `firefuel_env`, an unpublished empty package.
- Public exports of the internal query helpers (`QueryX`: `filterIfNotNull`, `sortIfNotNull`, …). Use [`FirefuelQuery`](firefuelapi.md#queries-as-values).

## New in 0.5

- [`FirefuelQuery`](firefuelapi.md#queries-as-values) with cursors and `limitToLast`, read through `query` / `streamQuery`
- [`Clause.or` / `Clause.and`](firefuelapi.md#or-and-and)
- [`aggregate`](firefuelapi.md#counting-and-aggregates): count, sums and averages in one request
- [`snapshots` / `docSnapshots`](firefuelapi.md#listening-with-metadata): ids, paths, changes, `isFromCache`, `hasPendingWrites`
- [`FirefuelCollectionGroup`](firefuelapi.md#collection-groups) and `FirefuelQueryRepository`
- [`FieldUpdate`](firefuelapi.md#field-updates), `ServerTimestamp`, `increment`, `deleteField`
- [Transactions](firefuelapi.md#transactions) and [atomic batches](firefuelapi.md#batches)
- [`FirefuelObserver`](firefuelapi.md#observing-failures) and [`WriteAcknowledgement`](firefuelapi.md#writing-while-offline)
- Re-exports of `FirebaseFirestore`, `Timestamp`, `Source`, `ListenSource`, `ServerTimestampBehavior`, `DocumentChangeType`, `DocumentReference`, `Transaction` and `WriteBatch`, so most apps need only one import
