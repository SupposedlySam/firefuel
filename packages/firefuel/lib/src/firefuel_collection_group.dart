import 'package:firefuel/firefuel.dart';

/// Every subcollection named [collectionId], wherever it lives, read as one
/// typed query.
///
/// Extend it like a [FirefuelCollection], implementing only
/// [fromFirestore]. You get the full read surface (`where`, `query`,
/// `paginate`, counts, aggregates, `streamWhere`, `snapshots`); there are no
/// writes, because a group has no single parent to write into.
///
/// ```dart
/// class ReactionGroup extends FirefuelCollectionGroup<Reaction> {
///   ReactionGroup() : super('reactions');
///
///   @override
///   Reaction? fromFirestore(snapshot, options) => switch (snapshot.data()) {
///     final data? => Reaction.fromJson(data),
///     null => null,
///   };
/// }
///
/// final reactions = ReactionGroup().snapshots(
///   FirefuelQuery(clauses: [Clause('conversationId', isEqualTo: id)]),
/// );
/// ```
///
/// Use `snapshots` when you need to know which parent each result came from:
/// every `FirefuelDoc` carries its path, and `ancestorId('messagePods')`
/// recovers the parent's id.
///
/// Firestore needs a collection-group index for most filtered group
/// queries; the error it returns links to the console page that creates it.
///
/// `Firefuel.env` is not applied: the environment prefixes top-level
/// collection names only, so a group spans every environment's
/// subcollections. Filter on a field if they share a database.
abstract class FirefuelCollectionGroup<T extends Serializable>
    with FirefuelQueryReads<T>
    implements CollectionGroup<T> {
  /// The group of every subcollection named [collectionId].
  ///
  /// Pass [firestore] to pin it to one instance; otherwise it uses
  /// `Firefuel.firestore` at the time of each call.
  FirefuelCollectionGroup(this.collectionId, {FirebaseFirestore? firestore})
    : _firestore = firestore;

  /// The subcollection id every member shares, e.g. `reactions`.
  final String collectionId;

  final FirebaseFirestore? _firestore;

  /// The instance this group reads.
  FirebaseFirestore get firestore => _firestore ?? Firefuel.firestore;

  /// Converts a document from any member of the group to a [T].
  T? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  @override
  Query<Map<String, dynamic>> get untypedBaseQuery {
    return firestore.collectionGroup(collectionId);
  }

  @override
  Query<T?> get baseQuery {
    return untypedBaseQuery.withConverter(
      fromFirestore: fromFirestore,
      toFirestore: (_, _) => throw UnsupportedError(
        'A collection group is read-only; write through the '
        'FirefuelCollection for the document instead.',
      ),
    );
  }
}
