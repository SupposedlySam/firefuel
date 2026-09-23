import 'dart:async';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/field_updates.dart';
import 'package:firefuel/src/utils/snapshot_converters.dart';

abstract class FirefuelCollection<T extends Serializable>
    with FirefuelQueryReads<T>
    implements Collection<T> {
  /// A collection at [path].
  ///
  /// Pass [firestore] to pin this collection to one instance (a named
  /// database, or a fake in tests). Without it, the collection uses
  /// `Firefuel.firestore` as it is at the time of each call.
  ///
  /// [path] is prefixed with `Firefuel.env` unless [useEnv] is false.
  FirefuelCollection(
    String path, {
    FirebaseFirestore? firestore,
    bool useEnv = true,
  }) : path = _buildPath(path, useEnv),
       _firestore = firestore;

  final String path;

  final FirebaseFirestore? _firestore;

  /// The instance this collection reads and writes.
  ///
  /// Resolved on every use rather than captured at construction. Until 0.5 a
  /// collection kept the instance that was current when it was built, so
  /// re-initializing Firefuel (to switch databases) silently left existing
  /// collections on the old one.
  FirebaseFirestore get firestore => _firestore ?? Firefuel.firestore;

  @override
  CollectionReference<T?> get ref {
    return untypedRef.withConverter(
      fromFirestore: fromFirestore,
      toFirestore: (model, options) {
        return FieldUpdates.lower(toFirestore(model, options));
      },
    );
  }

  CollectionReference<Map<String, dynamic>> get untypedRef {
    return firestore.collection(path);
  }

  @override
  Query<T?> get baseQuery => ref;

  @override
  Query<Map<String, dynamic>> get untypedBaseQuery => untypedRef;

  @override
  Future<DocumentId> create(T value) async {
    // doc() + set() instead of add(): the id exists before the write, so it
    // can be returned without waiting for the server.
    final doc = ref.doc();
    await _write(() => doc.set(value));

    return DocumentId(doc.id);
  }

  @override
  Future<DocumentId> createById({
    required T value,
    required DocumentId docId,
  }) async {
    await _write(() => ref.doc(docId.docId).set(value));

    return docId;
  }

  @override
  Future<void> delete(DocumentId docId) async {
    await _write(() => ref.doc(docId.docId).delete());
  }

  /// Converts a [DocumentSnapshot] to a [T?]
  T? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  /// Auto-generate a [DocumentId]
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  DocumentId generateDocId() => DocumentId(ref.doc().id);

  @override
  Future<T?> read(DocumentId docId, {GetOptions? getOptions}) async {
    final snapshot = await ref.doc(docId.docId).get(getOptions);
    return snapshot.data();
  }

  @override
  Future<List<T?>> readMany(List<DocumentId> docIds, {GetOptions? getOptions}) {
    return Future.wait(
      docIds.map((docId) => read(docId, getOptions: getOptions)),
    );
  }

  @override
  Future<T> readOrCreate({
    required DocumentId docId,
    required T createValue,
    GetOptions? getOptions,
  }) async {
    final maybeData = await read(docId, getOptions: getOptions);

    if (maybeData != null) return maybeData;

    await createById(value: createValue, docId: docId);

    final data = await read(docId, getOptions: getOptions);

    return data!;
  }

  @override
  Future<void> replace({required DocumentId docId, required T value}) {
    // update(), not a read followed by set(): the existence check then runs
    // on the server at commit, which is atomic, read-free and offline-safe.
    // See project_management/DESIGN.md D4.
    return _write(() => ref.doc(docId.docId).update(encode(value)));
  }

  @override
  Future<void> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) async {
    await _write(
      () => ref.doc(docId.docId).update(encodeFields(value, fieldPaths)),
    );

    return;
  }

  @override
  Stream<T?> stream(DocumentId docId) {
    return ref.doc(docId.docId).snapshots().toMaybeT();
  }

  @override
  Stream<FirefuelSnapshot<T?>> docSnapshots(
    DocumentId docId, {
    ListenOptions options = const ListenOptions(),
  }) {
    return ref
        .doc(docId.docId)
        .snapshots(
          includeMetadataChanges: options.includeMetadataChanges,
          source: options.source,
        )
        .map(Snapshots.document);
  }

  @override
  Stream<List<T?>> streamMany(List<DocumentId> docIds) {
    if (docIds.isEmpty) return Stream.value(<T?>[]);

    late StreamController<List<T?>> controller;
    final latest = List<T?>.filled(docIds.length, null);
    final hasValue = List<bool>.filled(docIds.length, false);
    final subscriptions = <StreamSubscription<T?>>[];

    void emitIfReady() {
      if (!hasValue.every((value) => value)) return;

      controller.add(List<T?>.unmodifiable(latest));
    }

    controller = StreamController<List<T?>>(
      onListen: () {
        for (final (index, docId) in docIds.indexed) {
          final subscription = stream(docId).listen((value) {
            latest[index] = value;
            hasValue[index] = true;
            emitIfReady();
          }, onError: controller.addError);
          subscriptions.add(subscription);
        }
      },
      onCancel: () async {
        await Future.wait(
          subscriptions.map((subscription) => subscription.cancel()),
        );
      },
    );

    return controller.stream;
  }

  /// Converts a [T?] to a [`Map<String, Object?>`] to upload to Firestore.
  ///
  /// May contain [FieldUpdate] values (for example a [ServerTimestamp] for a
  /// `createdAt` field); firefuel lowers them on every write.
  Map<String, Object?> toFirestore(T? model, SetOptions? options);

  /// The data firefuel writes for [value]: [toFirestore]'s output with every
  /// [FieldUpdate] lowered.
  ///
  /// Updates send this map through the typed [ref], not [untypedRef].
  /// Firestore itself does not care, but fake_cloud_firestore (which most
  /// consumers test with) notifies listeners per reference type, so a write
  /// through [untypedRef] never reaches a `stream` built on [ref].
  ///
  /// Every write (set, update, replace, and their batched forms) serializes
  /// through here. Before 0.5, `update` sent `value.toJson()` while `set`
  /// went through [toFirestore], so the two could disagree.
  Map<String, Object?> encode(T value) {
    return FieldUpdates.lower(toFirestore(value, null));
  }

  /// The data for [value], limited to [fieldPaths].
  Map<String, Object?> encodeFields(T value, List<String> fieldPaths) {
    return encode(value)..removeWhere((key, _) => !fieldPaths.contains(key));
  }

  @override
  Future<void> update({required DocumentId docId, required T value}) async {
    await _write(() => ref.doc(docId.docId).update(encode(value)));

    return;
  }

  @override
  Future<void> updateFields({
    required DocumentId docId,
    required Map<String, Object?> fields,
  }) async {
    await _write(() => ref.doc(docId.docId).update(FieldUpdates.lower(fields)));

    return;
  }

  @override
  Future<void> arrayUnion({
    required DocumentId docId,
    required String field,
    required List<Object?> values,
  }) {
    return updateFields(
      docId: docId,
      fields: {field: FieldUpdate.arrayUnion(values)},
    );
  }

  @override
  Future<void> arrayRemove({
    required DocumentId docId,
    required String field,
    required List<Object?> values,
  }) {
    return updateFields(
      docId: docId,
      fields: {field: FieldUpdate.arrayRemove(values)},
    );
  }

  @override
  Future<void> serverTimestamp({
    required DocumentId docId,
    required String field,
  }) {
    return updateFields(
      docId: docId,
      fields: {field: const FieldUpdate.serverTimestamp()},
    );
  }

  @override
  Future<void> increment({
    required DocumentId docId,
    required String field,
    required num by,
  }) {
    return updateFields(
      docId: docId,
      fields: {field: FieldUpdate.increment(by)},
    );
  }

  @override
  Future<void> deleteField({required DocumentId docId, required String field}) {
    return updateFields(
      docId: docId,
      fields: {field: const FieldUpdate.delete()},
    );
  }

  @override
  Future<T> updateOrCreate({
    required DocumentId docId,
    required T value,
  }) async {
    await _write(
      () => ref.doc(docId.docId).set(value, SetOptions(merge: true)),
    );

    return value;
  }

  @override
  Future<T?> whereById(DocumentId docId, {GetOptions? getOptions}) async {
    final snapshot = await ref
        .where(FieldPath.documentId, isEqualTo: docId.docId)
        .get(getOptions);

    final docs = snapshot.docs;

    if (docs.isEmpty) return null;

    return docs.first.data();
  }

  /// When this collection's writes complete. Defaults to
  /// `Firefuel.writeAcknowledgement`; override it to decide per collection.
  WriteAcknowledgement get writeAcknowledgement =>
      Firefuel.writeAcknowledgement;

  /// Runs [write] and completes as [writeAcknowledgement] says.
  ///
  /// With [WriteAcknowledgement.local] the write is queued and this returns
  /// at once; a later failure is reported to `Firefuel.observer`, since no
  /// caller is waiting for it any more.
  Future<void> _write(Future<void> Function() write) async {
    switch (writeAcknowledgement) {
      case WriteAcknowledgement.server:
        await write();
      case WriteAcknowledgement.local:
        unawaited(
          write().catchError(FirefuelFetchMixin.report),
        );
    }
  }

  /// Prefix the collection path with the environment
  ///
  /// if the environment isn't provided, the path is returned unaltered.
  static String _buildPath(String path, bool useEnv) {
    if (useEnv) return '${Firefuel.env}$path';

    return path;
  }
}
