import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, SnapshotMetadata;
import 'package:async/async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/snapshot_converters.dart';
import '../utils/test_collection.dart';
import '../utils/test_repository.dart';
import '../utils/test_user.dart';
import '../utils/test_backend.dart';

class _MockQuerySnapshot extends Mock implements QuerySnapshot<TestUser?> {}

// fake_cloud_firestore cannot produce pending or cached metadata, so the
// snapshot is mocked; cloud_firestore marks it @sealed only to keep apps
// from implementing it.
// ignore: subtype_of_sealed_class
class _MockDocSnapshot extends Mock
    implements QueryDocumentSnapshot<TestUser?> {}

class _MockMetadata extends Mock implements SnapshotMetadata {}

// ignore: subtype_of_sealed_class, see _MockDocSnapshot
class _MockQuery extends Mock implements Query<TestUser?> {}

/// A collection whose base query is a mock, to see what reaches Firestore.
class _SpyCollection extends TestCollection {
  _SpyCollection(this.spy);

  final Query<TestUser?> spy;

  @override
  Query<TestUser?> get baseQuery => spy;
}

// ignore: subtype_of_sealed_class, see _MockDocSnapshot
class _MockReference extends Mock implements DocumentReference<TestUser?> {}

void main() {
  late TestCollection collection;
  const fry = TestUser('Fry', age: 25);
  const leela = TestUser('Leela', age: 27);

  setUpAll(() => registerFallbackValue(ListenSource.defaultSource));

  setUp(() async {
    Firefuel.initialize(await testFirestore());
    collection = TestCollection();
  });

  tearDown(Firefuel.reset);

  group('#snapshots', () {
    test('should carry values, docs with ids and paths, and changes', () async {
      await collection.createById(value: fry, docId: DocumentId('fry'));
      await collection.createById(value: leela, docId: DocumentId('leela'));

      final snapshot = await collection
          .snapshots(
            FirefuelQuery(orderBy: [OrderBy(field: TestUser.fieldAge)]),
          )
          .first;

      expect(snapshot.value, [fry, leela]);
      expect(snapshot.docs.map((doc) => doc.id), ['fry', 'leela']);
      expect(snapshot.docs.first.path, 'testUsers/fry');
      expect(
        snapshot.changes.map((change) => change.type),
        everyElement(DocumentChangeType.added),
      );
    });

    test('should report a later modification as a change', () async {
      final docId = DocumentId('fry');
      await collection.createById(value: fry, docId: docId);

      final events = StreamQueue(collection.snapshots(FirefuelQuery()));
      // Wait until the listener has seen the document before changing it; a
      // real listener attaches asynchronously and may otherwise start after
      // the update.
      await expectLater(
        events,
        emitsThrough(
          isA<FirefuelQuerySnapshot<TestUser>>().having(
            (s) => s.value,
            'value',
            [fry],
          ),
        ),
      );

      await collection.update(docId: docId, value: leela);

      await expectLater(
        events,
        emitsThrough(
          isA<FirefuelQuerySnapshot<TestUser>>().having(
            (s) => s.changes.map((c) => (c.type, c.doc.value)).toList(),
            'changes',
            [(DocumentChangeType.modified, leela)],
          ),
        ),
      );
      await events.cancel();
    });

    test('the repository should wrap each snapshot in Right', () async {
      await collection.create(fry);
      final repository = TestRepository(collection: collection);

      final result = await repository.snapshots(FirefuelQuery()).first;

      expect(result.getRightOrElseNull()?.value, [fry]);
    });
  });

  group('#docSnapshots', () {
    test('should carry the value and metadata', () async {
      final docId = DocumentId('fry');
      await collection.createById(value: fry, docId: docId);

      final snapshot = await collection.docSnapshots(docId).first;

      expect(snapshot.value, fry);
      expect(snapshot.hasPendingWrites, isFalse);
    });

    test('should carry null for a missing document', () async {
      final snapshot = await collection
          .docSnapshots(DocumentId('nobody'))
          .first;

      expect(snapshot.value, isNull);
    });
  });

  group('metadata', () {
    test('should pass ListenOptions to Firestore', () {
      final spy = _MockQuery();
      when(
        () => spy.snapshots(
          includeMetadataChanges: any(named: 'includeMetadataChanges'),
          source: any(named: 'source'),
        ),
      ).thenAnswer((_) => const Stream.empty());

      _SpyCollection(spy).snapshots(
        FirefuelQuery(),
        options: const ListenOptions(
          includeMetadataChanges: true,
          source: ListenSource.cache,
        ),
      );

      verify(
        () => spy.snapshots(
          includeMetadataChanges: true,
          source: ListenSource.cache,
        ),
      ).called(1);
    });

    // fake_cloud_firestore always reports server-confirmed data, so the
    // mapping of pending and cached states is checked on mocked snapshots.
    test('should map isFromCache and hasPendingWrites through', () {
      final metadata = _MockMetadata();
      when(() => metadata.isFromCache).thenReturn(true);
      when(() => metadata.hasPendingWrites).thenReturn(true);

      final reference = _MockReference();
      when(() => reference.path).thenReturn('testUsers/fry');

      final doc = _MockDocSnapshot();
      when(() => doc.id).thenReturn('fry');
      when(() => doc.reference).thenReturn(reference);
      when(doc.data).thenReturn(fry);
      when(() => doc.metadata).thenReturn(metadata);

      final query = _MockQuerySnapshot();
      when(() => query.docs).thenReturn([doc]);
      when(() => query.docChanges).thenReturn([]);
      when(() => query.metadata).thenReturn(metadata);

      final snapshot = Snapshots.query(query);

      expect(snapshot.isFromCache, isTrue);
      expect(snapshot.hasPendingWrites, isTrue);
      expect(snapshot.docs.single.hasPendingWrites, isTrue);
      expect(snapshot.value, [fry]);
    });
  });

  group('$FirefuelDoc.ancestorId', () {
    const reaction = FirefuelDoc<TestUser>(
      id: 'u1',
      path: 'conversations/c1/messagePods/p1/reactions/u1',
      value: null,
      hasPendingWrites: false,
    );

    test('should find the id under each ancestor collection', () {
      expect(reaction.ancestorId('messagePods'), 'p1');
      expect(reaction.ancestorId('conversations'), 'c1');
    });

    test('should not treat the document itself as an ancestor', () {
      expect(reaction.ancestorId('reactions'), isNull);
    });

    test('should return null for a collection not on the path', () {
      expect(reaction.ancestorId('users'), isNull);
    });
  });
}
