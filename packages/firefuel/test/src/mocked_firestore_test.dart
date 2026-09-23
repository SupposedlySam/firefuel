// fake_cloud_firestore cannot hold a write open, report cached or pending
// metadata, or produce a document that fails to convert, so these tests
// mock cloud_firestore types. cloud_firestore marks them @sealed only to
// keep apps from implementing them.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentChange, SnapshotMetadata;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/snapshot_converters.dart';
import '../utils/test_collection.dart';
import '../utils/test_user.dart';

class _MockCollectionRef extends Mock
    implements CollectionReference<TestUser?> {}

class _MockDocRef extends Mock implements DocumentReference<TestUser?> {}

class _MockDocSnapshot extends Mock implements DocumentSnapshot<TestUser?> {}

class _MockQueryDocSnapshot extends Mock
    implements QueryDocumentSnapshot<TestUser?> {}

class _MockQuerySnapshot extends Mock implements QuerySnapshot<TestUser?> {}

class _MockChange extends Mock implements DocumentChange<TestUser?> {}

class _MockMetadata extends Mock implements SnapshotMetadata {}

/// A collection whose typed ref is a mock, to see what reaches Firestore.
class _SpyCollection extends TestCollection {
  _SpyCollection(this.spyRef);

  final CollectionReference<TestUser?> spyRef;

  @override
  CollectionReference<TestUser?> get ref => spyRef;
}

class _RecordingObserver extends FirefuelObserver {
  final failures = <Failure>[];

  @override
  void onFailure(Failure failure) => failures.add(failure);
}

SnapshotMetadata _metadata({required bool cache, required bool pending}) {
  final metadata = _MockMetadata();
  when(() => metadata.isFromCache).thenReturn(cache);
  when(() => metadata.hasPendingWrites).thenReturn(pending);
  return metadata;
}

void main() {
  const fry = TestUser('Fry');
  final fryId = DocumentId('fry');

  late _MockCollectionRef ref;
  late _MockDocRef doc;

  setUpAll(() {
    registerFallbackValue(ListenSource.defaultSource);
    registerFallbackValue(<Object, Object?>{});
  });

  setUp(() {
    ref = _MockCollectionRef();
    doc = _MockDocRef();
    when(() => ref.doc(any())).thenReturn(doc);
  });

  tearDown(Firefuel.reset);

  group('docSnapshots', () {
    setUp(() => Firefuel.initialize(FakeFirebaseFirestore()));

    test('should pass ListenOptions to Firestore', () {
      when(
        () => doc.snapshots(
          includeMetadataChanges: any(named: 'includeMetadataChanges'),
          source: any(named: 'source'),
        ),
      ).thenAnswer((_) => const Stream.empty());

      _SpyCollection(ref).docSnapshots(
        fryId,
        options: const ListenOptions(
          includeMetadataChanges: true,
          source: ListenSource.cache,
        ),
      );

      verify(
        () => doc.snapshots(
          includeMetadataChanges: true,
          source: ListenSource.cache,
        ),
      ).called(1);
    });

    test('should map each metadata flag to its own field', () {
      final snapshot = _MockDocSnapshot();
      when(snapshot.data).thenReturn(fry);
      final snapshotMetadata = _metadata(cache: true, pending: false);
      when(() => snapshot.metadata).thenReturn(snapshotMetadata);

      final mapped = Snapshots.document(snapshot);

      expect(mapped.value, fry);
      expect(mapped.isFromCache, isTrue);
      expect(mapped.hasPendingWrites, isFalse);
    });
  });

  group('query snapshots', () {
    _MockQueryDocSnapshot docSnapshot(String id, TestUser? value) {
      final reference = _MockDocRef();
      when(() => reference.path).thenReturn('testUsers/$id');
      final snapshot = _MockQueryDocSnapshot();
      when(() => snapshot.id).thenReturn(id);
      when(() => snapshot.reference).thenReturn(reference);
      when(snapshot.data).thenReturn(value);
      final snapshotMetadata = _metadata(cache: false, pending: false);
      when(() => snapshot.metadata).thenReturn(snapshotMetadata);
      return snapshot;
    }

    test('should keep unconvertible docs in docs but not in value', () {
      final kept = docSnapshot('fry', fry);
      final unconvertible = docSnapshot('broken', null);
      final query = _MockQuerySnapshot();
      when(() => query.docs).thenReturn([kept, unconvertible]);
      when(() => query.docChanges).thenReturn([]);
      final queryMetadata = _metadata(cache: false, pending: false);
      when(() => query.metadata).thenReturn(queryMetadata);

      final mapped = Snapshots.query(query);

      expect(mapped.value, [fry]);
      expect(mapped.docs.map((doc) => doc.id), ['fry', 'broken']);
    });

    test('should carry each change with its old and new index', () {
      final changed = docSnapshot('fry', fry);
      final change = _MockChange();
      when(() => change.type).thenReturn(DocumentChangeType.added);
      when(() => change.doc).thenReturn(changed);
      when(() => change.oldIndex).thenReturn(-1);
      when(() => change.newIndex).thenReturn(0);
      final query = _MockQuerySnapshot();
      when(() => query.docs).thenReturn([]);
      when(() => query.docChanges).thenReturn([change]);
      final queryMetadata = _metadata(cache: false, pending: false);
      when(() => query.metadata).thenReturn(queryMetadata);

      final mapped = Snapshots.query(query).changes.single;

      expect(mapped.oldIndex, -1);
      expect(mapped.newIndex, 0);
      expect(mapped.type, DocumentChangeType.added);
    });
  });

  group('WriteAcknowledgement.local', () {
    test('should return before the server answers', () async {
      final observer = _RecordingObserver();
      Firefuel.initialize(
        FakeFirebaseFirestore(),
        observer: observer,
        writeAcknowledgement: WriteAcknowledgement.local,
      );
      final server = Completer<void>();
      when(() => doc.update(any())).thenAnswer((_) => server.future);

      // The server never answers during this call; a write that waited for
      // it would time out here.
      await _SpyCollection(
        ref,
      ).replace(docId: fryId, value: fry).timeout(const Duration(seconds: 1));
      expect(observer.failures, isEmpty);

      server.completeError(StateError('rejected by security rules'));
      await pumpEventQueue();

      expect(observer.failures.single.error, isA<StateError>());
    });

    test('server acknowledgement should wait for the server', () async {
      Firefuel.initialize(FakeFirebaseFirestore());
      final server = Completer<void>();
      when(() => doc.update(any())).thenAnswer((_) => server.future);

      var returned = false;
      unawaited(
        _SpyCollection(
          ref,
        ).replace(docId: fryId, value: fry).then((_) => returned = true),
      );
      await pumpEventQueue();
      expect(returned, isFalse);

      server.complete();
      await pumpEventQueue();
      expect(returned, isTrue);
    });
  });
}
