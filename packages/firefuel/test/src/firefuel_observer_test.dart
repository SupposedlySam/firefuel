import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:firefuel/firefuel.dart';
import '../utils/test_collection.dart';
import '../utils/test_repository.dart';
import '../utils/test_user.dart';

class RecordingObserver extends FirefuelObserver {
  final failures = <Failure>[];

  @override
  void onFailure(Failure failure) => failures.add(failure);
}

void main() {
  late RecordingObserver observer;
  final missing = DocumentId('missing');
  const fry = TestUser('Fry');

  setUp(() => observer = RecordingObserver());

  tearDown(Firefuel.reset);

  group('observer', () {
    setUp(
      () => Firefuel.initialize(FakeFirebaseFirestore(), observer: observer),
    );

    test('should hear every failure a repository returns', () async {
      final repository = TestRepository(collection: TestCollection());

      final result = await repository.replace(docId: missing, value: fry);

      expect(result.isLeft(), isTrue);
      expect(observer.failures, [result.getLeft()]);
    });

    test('should hear nothing when calls succeed', () async {
      final repository = TestRepository(collection: TestCollection());

      final result = await repository.create(fry);

      // Positive control: the call ran and succeeded.
      expect(result.isRight(), isTrue);
      expect(observer.failures, isEmpty);
    });

    test('should hear stream failures', () async {
      final repository = TestRepository(collection: TestCollection());

      final results = await repository
          .streamQuery(FirefuelQuery(limit: -1))
          .toList();

      expect(results.single.isLeft(), isTrue);
      expect(observer.failures, hasLength(1));
    });

    test('reset should restore the default observer', () {
      Firefuel.reset();

      expect(Firefuel.observer.runtimeType, FirefuelObserver);
    });
  });

  test('the default observer should not throw', () {
    expect(
      () => const FirefuelObserver().onFailure(_TestFailure('boom')),
      returnsNormally,
    );
    expect(
      () => const SilentFirefuelObserver().onFailure(_TestFailure('boom')),
      returnsNormally,
    );
  });

  group('writeAcknowledgement', () {
    test('server should surface a rejected write to the caller', () async {
      Firefuel.initialize(FakeFirebaseFirestore(), observer: observer);

      await expectLater(
        TestCollection().replace(docId: missing, value: fry),
        throwsA(isA<Exception>()),
      );
      expect(observer.failures, isEmpty);
    });

    test('local should return at once and report a later rejection', () async {
      Firefuel.initialize(
        FakeFirebaseFirestore(),
        observer: observer,
        writeAcknowledgement: WriteAcknowledgement.local,
      );

      await TestCollection().replace(docId: missing, value: fry);
      // Let the queued write settle.
      await pumpEventQueue();

      expect(observer.failures, hasLength(1));
    });

    test('local should still apply successful writes', () async {
      Firefuel.initialize(
        FakeFirebaseFirestore(),
        observer: observer,
        writeAcknowledgement: WriteAcknowledgement.local,
      );
      final users = TestCollection();

      final id = await users.create(fry);
      await pumpEventQueue();

      expect(await users.read(id), fry);
      expect(observer.failures, isEmpty);
    });

    test('a collection should be able to override the default', () async {
      Firefuel.initialize(
        FakeFirebaseFirestore(),
        observer: observer,
        writeAcknowledgement: WriteAcknowledgement.local,
      );

      await expectLater(
        _ServerAckCollection().replace(docId: missing, value: fry),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class _ServerAckCollection extends TestCollection {
  @override
  WriteAcknowledgement get writeAcknowledgement => WriteAcknowledgement.server;
}

class _TestFailure extends Failure {
  _TestFailure(super.error) : super(stackTrace: Chain.current());
}
