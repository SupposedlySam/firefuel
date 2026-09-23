import 'package:firefuel/firefuel.dart';

/// Everything that can be read from a query of [T] documents: reads,
/// counts, aggregates, pagination and listening.
///
/// A [Collection] adds document-level reads and writes; a [CollectionGroup]
/// is exactly this.
abstract class ReadableQuery<T extends Serializable>
    implements
        CollectionAggregate<double?>,
        CollectionCount<int>,
        CollectionPaginate<Chunk<T>, T>,
        CollectionRead<List<T>, T>,
        QueryAggregate<AggregateResult>,
        QueryListen<FirefuelQuerySnapshot<T>> {}

abstract class Collection<T extends Serializable>
    implements
        ReadableQuery<T>,
        DocCreate<DocumentId, T>,
        DocCreateIfNotExist<T, T>,
        DocListen<FirefuelSnapshot<T?>>,
        DocDelete<void>,
        DocRead<T?>,
        DocReadMany<List<T?>>,
        DocReplace<void, T>,
        DocUpdate<void, T> {
  const Collection(); // coverage:ignore-line

  CollectionReference<T?> get ref;
}

/// Every subcollection with one id, wherever it lives, read as one query.
///
/// Read-only: a group has no single parent to create documents in.
abstract class CollectionGroup<T extends Serializable>
    implements ReadableQuery<T> {}
