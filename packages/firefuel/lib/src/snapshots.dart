import 'package:equatable/equatable.dart';

import 'package:firefuel/firefuel.dart';

/// How to listen: whether metadata-only changes emit, and where data comes
/// from.
class ListenOptions extends Equatable {
  const ListenOptions({
    this.includeMetadataChanges = false,
    this.source = ListenSource.defaultSource,
  });

  /// Emit again when only the metadata changes, most usefully when a local
  /// write is confirmed by the server (`hasPendingWrites` turning false) or
  /// cached data is replaced by server data (`isFromCache` turning false).
  ///
  /// Without it, a "syncing" indicator never learns that syncing finished.
  final bool includeMetadataChanges;

  /// [ListenSource.cache] listens to the local cache only, never the server.
  final ListenSource source;

  @override
  List<Object?> get props => [includeMetadataChanges, source];
}

/// The results of `aggregate`.
class AggregateResult extends Equatable {
  const AggregateResult({
    this.count,
    this.sums = const {},
    this.averages = const {},
  });

  /// How many documents matched, if a count was requested.
  final int? count;

  /// The sum of each requested field. `null` for a field no matching
  /// document holds a number in.
  final Map<String, double?> sums;

  /// The average of each requested field. `null` for a field no matching
  /// document holds a number in.
  final Map<String, double?> averages;

  @override
  List<Object?> get props => [count, sums, averages];
}

/// A value read from Firestore, together with where it came from.
class FirefuelSnapshot<R> extends Equatable {
  const FirefuelSnapshot({
    required this.value,
    required this.isFromCache,
    required this.hasPendingWrites,
  });

  /// The data.
  final R value;

  /// Whether [value] came from the local cache rather than a server
  /// response, for example while offline or before the first server reply.
  final bool isFromCache;

  /// Whether [value] includes local writes the server has not confirmed yet.
  final bool hasPendingWrites;

  @override
  List<Object?> get props => [value, isFromCache, hasPendingWrites];
}

/// One document in a snapshot: its data plus where it lives.
class FirefuelDoc<T> extends Equatable {
  const FirefuelDoc({
    required this.id,
    required this.path,
    required this.value,
    required this.hasPendingWrites,
  });

  /// The document's id.
  final String id;

  /// The document's full path, e.g. `conversations/c1/messagePods/p1`.
  final String path;

  /// The converted data, or `null` if it does not exist or did not convert.
  final T? value;

  /// Whether this document has local writes the server has not confirmed.
  final bool hasPendingWrites;

  /// The id of the ancestor document inside the [collectionId] collection,
  /// or `null` if [collectionId] is not in this document's path.
  ///
  /// Documents read through a collection group come from many parents; this
  /// recovers which one. For `conversations/c1/messagePods/p1/reactions/u1`,
  /// `ancestorId('messagePods')` is `p1`.
  String? ancestorId(String collectionId) {
    final segments = path.split('/');
    // Collection ids sit at even indexes, each followed by its document id.
    // The last pair is this document itself, so it is skipped.
    for (var i = segments.length - 4; i >= 0; i -= 2) {
      if (segments[i] == collectionId) return segments[i + 1];
    }
    return null;
  }

  @override
  List<Object?> get props => [id, path, value, hasPendingWrites];
}

/// How a document changed between two snapshots of a query.
class FirefuelDocChange<T> extends Equatable {
  const FirefuelDocChange({
    required this.type,
    required this.doc,
    required this.oldIndex,
    required this.newIndex,
  });

  final DocumentChangeType type;

  /// The document after the change (its last state, for a removal).
  final FirefuelDoc<T> doc;

  /// Position before the change, or -1 if it was added.
  final int oldIndex;

  /// Position after the change, or -1 if it was removed.
  final int newIndex;

  @override
  List<Object?> get props => [type, doc, oldIndex, newIndex];
}

/// Every document a query matched, what changed since the previous
/// snapshot, and where the data came from.
class FirefuelQuerySnapshot<T> extends FirefuelSnapshot<List<T>> {
  const FirefuelQuerySnapshot({
    required super.value,
    required this.docs,
    required this.changes,
    required super.isFromCache,
    required super.hasPendingWrites,
  });

  /// The matching documents with their ids and paths, in query order.
  ///
  /// [value] holds the same documents' data, without the ones that are
  /// null.
  final List<FirefuelDoc<T>> docs;

  /// What changed since the previous snapshot. For the first snapshot,
  /// every document is an `added` change.
  final List<FirefuelDocChange<T>> changes;

  @override
  List<Object?> get props => [...super.props, docs, changes];
}
