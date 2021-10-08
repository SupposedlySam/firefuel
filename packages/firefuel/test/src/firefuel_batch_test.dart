import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_collection.dart';
import '../utils/test_user.dart';

void main() {
  late FirefuelBatch<TestUser> testBatch;
  final batman = TestUser('Bruce Wayne');

  setUp(() {
    Firefuel.initialize(FakeFirebaseFirestore());

    final testCollection = TestCollection();
    testBatch = FirefuelBatch(testCollection);
  });

  group('#size', () {
    test('should start at 0', () {
      expect(testBatch.size, 0);
    });

    test('should increase when transaction occurs', () async {
      await testBatch.create(batman);

      expect(testBatch.size, 1);
    });

    test('should return 1 after maxSize + 1 is reached', () async {
      final overSize = testBatch.maxSize + 1;

      for (var i = 0; i < overSize; i++) {
        await testBatch.create(batman);
      }

      expect(testBatch.size, 1);
    });

    test('should return 0 after commit occurs', () async {
      await testBatch.create(batman);

      await testBatch.commit();

      expect(testBatch.size, 0);
    });
  });

  group('#totalTransactionsCommitted', () {
    test('should start at 0', () {
      expect(testBatch.totalTransactionsCommitted, 0);
    });

    test('should increase when transaction is committed', () async {
      await testBatch.create(batman);

      await testBatch.commit();

      expect(testBatch.totalTransactionsCommitted, 1);
    });

    test('should return 501 when 501 transactions are committed', () async {
      final overSize = 501;

      for (var i = 0; i < overSize; i++) {
        await testBatch.create(batman);
      }

      await testBatch.commit();

      expect(testBatch.totalTransactionsCommitted, overSize);
    });
  });

  group('#commit', () {
    test('should return 1 when one transaction is committed', () async {
      await testBatch.create(batman);

      final result = await testBatch.commit();

      expect(result, 1);
    });

    test('should return a new batch after its committed', () async {
      final originalBatch = testBatch.batch;

      await testBatch.create(batman);

      await testBatch.commit();

      final newBatch = testBatch.batch;

      expect(originalBatch, isNot(newBatch));
    });
  });
}
