import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/test_collection.dart';
import '../utils/test_user.dart';

void main() {
  late FirefuelBatch<TestUser> testBatch;
  late TestCollection testCollection;
  final batman = TestUser('Bruce Wayne');

  setUp(() {
    Firefuel.initialize(FakeFirebaseFirestore());

    testCollection = TestCollection();
    testBatch = FirefuelBatch(testCollection);
  });

  group('#size', () {
    test('should start at 0', () {
      expect(testBatch.transactionSize, 0);
    });

    test('should increase when transaction occurs', () async {
      await testBatch.create(batman);

      expect(testBatch.transactionSize, 1);
    });

    test('should return 1 after maxSize + 1 is reached', () async {
      final overSize = testBatch.transactionLimit + 1;

      for (var i = 0; i < overSize; i++) {
        await testBatch.create(batman);
      }

      expect(testBatch.transactionSize, 1);
    });

    test('should return 0 after committed', () async {
      await testBatch.create(batman);

      await testBatch.commit();

      expect(testBatch.transactionSize, 0);
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

    group('should persist transaction count across batches', () {
      test('when auto-commit takes place', () async {
        final overSize = testBatch.transactionLimit + 1;

        for (var i = 0; i < overSize; i++) {
          await testBatch.create(batman);
        }

        await testBatch.commit();

        expect(testBatch.totalTransactionsCommitted, overSize);
      });

      test('when manually committing', () async {
        final batchedTransactionCount = 20;
        final batches = 2;
        final expectedCount = batches * batchedTransactionCount;

        for (var b = 0; b < batches; b++) {
          for (var t = 0; t < batchedTransactionCount; t++) {
            await testBatch.create(batman);
          }

          await testBatch.commit();
        }

        expect(testBatch.totalTransactionsCommitted, expectedCount);
      });
    });
  });

  group('#commit', () {
    test('should reset the transactionSize to zero', () async {
      await testBatch.create(batman);

      await testBatch.commit();

      expect(testBatch.transactionSize, isZero);
    });

    test('should create new batch', () async {
      final originalBatch = testBatch.batch;

      await testBatch.create(batman);

      await testBatch.commit();

      final newBatch = testBatch.batch;

      expect(originalBatch, isNot(newBatch));
    });

    test('should auto-commit after the transactionLimit', () async {
      final overSize = testBatch.transactionLimit + 1;

      for (var i = 0; i < overSize; i++) {
        await testBatch.create(batman);
      }

      expect(testBatch.transactionSize, 1);
    });
  });

  group('#create', () {
    test('should add user to database', () async {
      await testBatch.create(batman);

      await testBatch.commit();

      final result = await testCollection.readAll();

      expect(result, [batman]);
    });

    test('should add multiple users to database', () async {
      await testBatch.create(batman);
      await testBatch.create(batman);

      await testBatch.commit();

      final results = await testCollection.readAll();

      expect(results, [batman, batman]);
    });
  });

  group('#createById', () {
    final originalDocId = DocumentId('originalDocId');

    test('should create the document with provided id', () async {
      await testBatch.createById(
        value: batman,
        docId: originalDocId,
      );

      await testBatch.commit();

      final readResult = await testCollection.read(originalDocId);

      expect(batman, readResult);
    });
  });

  group('#delete', () {
    late final DocumentId defaultDocId;

    setUp(() async {
      defaultDocId = await testCollection.create(batman);
    });

    test('should remove the document', () async {
      await testBatch.delete(defaultDocId);

      await testBatch.commit();

      final readResult = await testCollection.read(defaultDocId);

      expect(readResult, isNull);
    });
  });

  group('#replace', () {
    final originalDocId = DocumentId('originalDocId');

    test('should fail silently when document does not exist', () async {
      final dodoId = DocumentId('dodoId');

      await testBatch.replace(
        docId: dodoId,
        value: TestUser('Clark Kent'),
      );

      await testBatch.commit();

      final readResult = await testCollection.read(dodoId);

      expect(readResult, isNull);
    });

    test('should overwrite all values in document', () async {
      final newUser = TestUser('newUser');
      final updatedUser = TestUser('updatedUser');

      await testBatch.createById(value: newUser, docId: originalDocId);
      await testBatch.commit();

      await testBatch.replace(
        value: updatedUser,
        docId: originalDocId,
      );

      await testBatch.commit();

      final readUser = await testCollection.read(originalDocId);

      expect(updatedUser, readUser);
    });
  });

  group('#replaceFields', () {
    late DocumentId docId;
    const replacementName = 'someNewValue';
    final replacement = TestUser(replacementName);

    setUp(() async {
      docId = await testCollection.create(batman);
    });

    test('should replace fields in the list', () async {
      await testBatch.replaceFields(
        docId: docId,
        value: replacement,
        fieldPaths: [TestUser.fieldName],
      );

      await testBatch.commit();

      final updatedUser = await testCollection.read(docId);

      expect(updatedUser!.name, replacementName);
    });

    test('should not replace fields missing from the list', () async {
      const replacementName = 'someNewValue';
      final replacement = TestUser(replacementName);

      await testBatch.replaceFields(
        docId: docId,
        value: replacement,
        fieldPaths: ['fakeField'],
      );

      await testBatch.commit();

      final unchangedUser = await testCollection.read(docId);

      expect(unchangedUser!.name, isNot(replacementName));
    });
  });

  group('#reset', () {
    test('should set transactionSize back to zero', () async {
      await testBatch.create(batman);
      await testBatch.create(batman);

      expect(testBatch.transactionSize, 2);

      testBatch.reset();

      expect(testBatch.transactionSize, isZero);
    });

    test('should set transactionSize back to zero', () {
      final batch1 = identityHashCode(testBatch.batch);

      testBatch.reset();

      final batch2 = identityHashCode(testBatch.batch.hashCode);

      expect(batch1, isNot(batch2));
    });
  });

  group('#update', () {
    test('should overwrite existing fields', () async {
      final updatedDoc = TestUser('updateValue');
      final docId = await testCollection.create(batman);

      await testBatch.update(
        docId: docId,
        value: updatedDoc,
      );

      await testBatch.commit();

      final readResult = await testCollection.read(docId);

      expect(readResult, updatedDoc);
    });
  });

  group('#updateOrCreate', () {
    test('should create new document when document does not exist', () async {
      final originalDocId = DocumentId('originalDocId');
      final newUser = TestUser('newUser');

      await testBatch.updateOrCreate(
        docId: originalDocId,
        value: newUser,
      );

      await testBatch.commit();

      final updatedDoc = await testCollection.read(originalDocId);

      expect(updatedDoc, newUser);
    });

    test('should overwrite existing fields', () async {
      final updatedDoc = TestUser('updateValue');
      final docId = await testCollection.create(batman);

      await testBatch.updateOrCreate(
        docId: docId,
        value: updatedDoc,
      );

      await testBatch.commit();

      final readResult = await testCollection.read(docId);

      expect(readResult, updatedDoc);
    });
  });
}
