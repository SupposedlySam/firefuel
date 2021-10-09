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

    test('should return batman new batch after its committed', () async {
      final originalBatch = testBatch.batch;

      await testBatch.create(batman);

      await testBatch.commit();

      final newBatch = testBatch.batch;

      expect(originalBatch, isNot(newBatch));
    });
  });

  group('#create', () {
    test('should return 2 new documents', () async {
      await testBatch.create(batman);
      await testBatch.create(batman);

      final createdCount = await testBatch.commit();

      final results = await testCollection.readAll();

      expect(createdCount, 2);
      expect(results.length, 2);
    });

    test('should create batman new document with the values provided',
        () async {
      final newUser = TestUser('overwrittenUser');
      await testBatch.create(newUser);

      await testBatch.commit();

      final result = await testCollection.limit(1);
      final updatedUser = result.first;

      expect(updatedUser, newUser);
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
    late DocumentId defaultDocId;

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

    // TODO: https://github.com/SupposedlySam/firefuel/issues/43
    test('should overwrite all values in document', () async {
      final newUser = TestUser('newUser');
      final updatedUser = TestUser('updatedUser');

      await testBatch.createById(value: newUser, docId: originalDocId);

      await testBatch.replace(
        value: updatedUser,
        docId: originalDocId,
      );

      await testBatch.commit();

      final readUser = await testCollection.read(originalDocId);

      expect(updatedUser, readUser);
    }, skip: true);
  });

  group('#replaceFields', () {
    late DocumentId docId;
    const replacementName = 'someNewValue';
    final replacement = TestUser(replacementName);

    setUp(() async {
      docId = await testCollection.create(batman);
    });

    // TODO: not sure if this is a bug with firebase or fake_cloud_firestore
    // This test fails because if the document is not found, the batch
    // creates a new document with the provided fields.
    test('should fail silently when document does not exist', () async {
      final dodoId = DocumentId('dodoBird');

      await testBatch.replaceFields(
        docId: dodoId,
        value: TestUser('Clark Kent'),
        fieldPaths: [TestUser.fieldName],
      );

      await testBatch.commit();

      final readResult = await testCollection.read(dodoId);

      expect(readResult, isNull);
    }, skip: true);

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

  group('#update', () {
    // TODO: not sure if this is a bug with firebase or fake_cloud_firestore
    // This test fails because if the document is not found, the batch
    // creates a new document with the provided fields.
    test('should fail silently when document does not exist', () async {
      final dodoId = DocumentId('dodoBird');
      await testBatch.update(
        docId: dodoId,
        value: TestUser('Clark Kent'),
      );

      await testBatch.commit();

      final readResult = await testCollection.read(dodoId);

      expect(readResult, isNull);
    }, skip: true);

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
