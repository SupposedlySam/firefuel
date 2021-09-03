import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test/test.dart';

import 'package:firefuel/firefuel.dart';
import '../utils/test_user.dart';

const _testUsersCollectionName = 'testUsers';

void main() {
  late TestCollection testCollection;
  final defaultUser = TestUser('testName');

  setUp(() {
    Firefuel.initialize(FakeFirebaseFirestore());
    testCollection = TestCollection();
  });

  group('#create', () {
    test('should return a new document', () async {
      final originalDocId = await testCollection.create(defaultUser);
      final secondDocId = await testCollection.create(defaultUser);

      expect(originalDocId, isNot(secondDocId));
    });

    test('should create a new document with the values provided', () async {
      final newUser = TestUser('overwrittenUser');
      final createdDocId = await testCollection.create(newUser);

      final updatedUser = await testCollection.read(createdDocId);

      expect(updatedUser, newUser);
    });
  });

  group('#createById', () {
    final originalDocId = DocumentId('originalDocId');

    test('should create the document with provided id', () async {
      await testCollection.createById(
        value: defaultUser,
        docId: originalDocId,
      );

      final readResult = await testCollection.read(originalDocId);

      expect(defaultUser, readResult);
    });

    test('should overwrite the document with the values provided', () async {
      final newUser = TestUser('newUser');
      final createdDocId = await testCollection.create(newUser);

      final updatedUser = TestUser('updatedUser');
      await testCollection.createById(
        value: updatedUser,
        docId: createdDocId,
      );

      final overwrittenUser = await testCollection.read(createdDocId);

      expect(updatedUser, overwrittenUser);
    });
  });

  group('#delete', () {
    late DocumentId defaultDocId;

    setUp(() async {
      defaultDocId = await testCollection.create(defaultUser);
    });

    test('should remove the document', () async {
      await testCollection.delete(defaultDocId);

      final readResult = await testCollection.read(defaultDocId);

      expect(readResult, isNull);
    });
  });

  group('#readOrCreate', () {
    final documentId = DocumentId('testName');

    test('should create the doc when it does not exist', () async {
      final result = await testCollection.readOrCreate(
          docId: documentId, createValue: defaultUser);

      expect(result, defaultUser);
    });

    test('should get doc when it exists', () async {
      final docId = await testCollection.create(defaultUser);

      final testUser = await testCollection.readOrCreate(
          docId: docId, createValue: defaultUser);

      expect(docId.docId, testUser.docId);
    });
  });

  group('#listen', () {
    late Stream<TestUser?> stream;
    late DocumentId docId;

    setUp(() async {
      docId = await testCollection.create(defaultUser);

      stream = testCollection.listen(testCollection.collectionRef, docId);
    });

    test('should output new value when doc updates', () async {
      final newUser1 = TestUser('newUser1');
      final newUser2 = TestUser('newUser2');
      final newUser3 = TestUser('newUser3');

      expect(stream, emitsInOrder([newUser1, newUser2, newUser3]));

      await testCollection.update(docId: docId, value: newUser1);
      await testCollection.update(docId: docId, value: newUser2);
      await testCollection.update(docId: docId, value: newUser3);
    });

    test('should output null when doc no longer exists', () async {
      final newUser = TestUser('newUser');

      expect(stream, emitsInOrder([newUser, null]));

      await testCollection.update(docId: docId, value: newUser);
      await testCollection.delete(docId);
    });
  });

  group('#listenAll', () {
    late Stream<List<TestUser>> stream;
    late DocumentId docId;
    final newUser1 = TestUser('newUser1');
    final newUser2 = TestUser('newUser2');

    setUp(() async {
      docId = await testCollection.create(defaultUser);
      await testCollection.create(newUser1);

      stream = testCollection.listenAll(testCollection.collectionRef);
    });

    test('should update when an item is added', () async {
      expect(
        stream,
        emitsInOrder([
          [defaultUser, newUser1],
          [defaultUser, newUser1, newUser2],
        ]),
      );

      await testCollection.create(newUser2);
    });

    test('should update when an item is deleted', () async {
      expect(
        stream,
        emitsInOrder([
          [newUser1],
        ]),
      );

      await testCollection.delete(docId);
    });
  });

  group('#read', () {
    test('should return the Type when docId exists', () async {
      final docId = await testCollection.create(defaultUser);

      final readResult = await testCollection.read(docId);

      expect(readResult, defaultUser);
    });

    test('should return null when docId does not exist', () async {
      final readResult = await testCollection.read(DocumentId('dodoBird'));

      expect(readResult, isNull);
    });
  });

  group('#readAsStream', () {
    late Stream<TestUser?> docStream;
    late DocumentId docId;

    setUp(() async {
      docId = await testCollection.create(defaultUser);

      docStream = testCollection.readAsStream(docId);
    });

    test('should update when a field changes', () async {
      final updatedUser = TestUser('updatedValue');

      expect(
        docStream,
        emitsInOrder([updatedUser]),
      );

      await testCollection.update(
        docId: docId,
        value: updatedUser,
      );
    });

    test('should update when document is deleted', () async {
      expect(
        docStream,
        emitsInOrder([null]),
      );

      await testCollection.delete(docId);
    });
  });

  group('#replace', () {
    final originalDocId = DocumentId('originalDocId');

    test('should fail silently when document does not exist', () async {
      final updateResult = await testCollection.replace(
        docId: DocumentId('dodoBird'),
        value: TestUser('Clark Kent'),
      );

      expect(updateResult, isNull);
    });

    test('should overwrite all values in document', () async {
      final newUser = TestUser('newUser');
      final updatedUser = TestUser('updatedUser');

      await testCollection.createById(value: newUser, docId: originalDocId);

      await testCollection.replace(
        value: updatedUser,
        docId: originalDocId,
      );

      final readUser = await testCollection.read(originalDocId);

      expect(updatedUser, readUser);
    });
  });

  group('#replaceFields', () {
    late DocumentId docId;
    const replacementName = 'someNewValue';
    final replacement = TestUser(replacementName);

    setUp(() async {
      docId = await testCollection.create(defaultUser);
    });

    test('should fail silently when document does not exist', () async {
      final updateResult = await testCollection.replaceFields(
        docId: DocumentId('dodoBird'),
        value: TestUser('Clark Kent'),
        fieldPaths: [TestUser.fieldName],
      );

      expect(updateResult, isNull);
    });

    test('should replace fields in the list', () async {
      await testCollection.replaceFields(
        docId: docId,
        value: replacement,
        fieldPaths: [TestUser.fieldName],
      );

      final updatedUser = await testCollection.read(docId);

      expect(updatedUser!.name, replacementName);
    });

    test('should not replace fields missing from the list', () async {
      const replacementName = 'someNewValue';
      final replacement = TestUser(replacementName);

      await testCollection.replaceFields(
        docId: docId,
        value: replacement,
        fieldPaths: ['fakeField'],
      );

      final unchangedUser = await testCollection.read(docId);

      expect(unchangedUser!.name, isNot(replacementName));
    });
  });

  group('#update', () {
    test('should fail silently when document does not exist', () async {
      final updateResult = await testCollection.update(
        docId: DocumentId('dodoBird'),
        value: TestUser('Clark Kent'),
      );

      expect(updateResult, isNull);
    });

    test('should overwrite existing fields', () async {
      final updatedDoc = TestUser('updateValue');
      final docId = await testCollection.create(defaultUser);

      await testCollection.update(
        docId: docId,
        value: updatedDoc,
      );

      final readResult = await testCollection.read(docId);

      expect(readResult, updatedDoc);
    });
  });

  group('#updateOrCreate', () {
    test('should create new document when document does not exist', () async {
      final originalDocId = DocumentId('originalDocId');
      final newUser = TestUser('newUser');

      await testCollection.updateOrCreate(
        docId: originalDocId,
        value: newUser,
      );

      final updatedDoc = await testCollection.read(originalDocId);

      expect(updatedDoc, newUser);
    });

    test('should overwrite existing fields', () async {
      final updatedDoc = TestUser('updateValue');
      final docId = await testCollection.create(defaultUser);

      await testCollection.updateOrCreate(
        docId: docId,
        value: updatedDoc,
      );

      final readResult = await testCollection.read(docId);

      expect(readResult, updatedDoc);
    });
  });
}

class TestCollection extends FirefuelCollection<TestUser> {
  TestCollection() : super(_testUsersCollectionName);

  @override
  TestUser? fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return data == null
        ? null
        : TestUser.fromJson(snapshot.data()!, snapshot.id);
  }

  @override
  Map<String, Object?> toFirestore(TestUser? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
