import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:test/test.dart';

import '../utils/test_user.dart';

const _testUsersCollectionName = 'testUsers';

void main() {
  late FirebaseFirestore instance;
  late TestCollection testCollection;
  final defaultUser = TestUser('testName');

  setUp(() {
    instance = FakeFirebaseFirestore();
    testCollection = TestCollection(instance);
  });

  group('#create', () {
    late DocumentId originalDocId;

    setUp(() async {
      originalDocId = await testCollection.create(value: defaultUser);
    });

    group('when docId is provided', () {
      test('should return the same document', () async {
        final createResult = await testCollection.create(
          value: defaultUser,
          docId: originalDocId,
        );

        expect(originalDocId, createResult);
      });

      test('should overwrite the document with the values provided', () async {
        final newUser = TestUser('overwrittenUser');
        final createdDocId = await testCollection.create(
          value: newUser,
          docId: originalDocId,
        );

        final updatedUser = await testCollection.read(createdDocId);

        expect(updatedUser, newUser);
      });
    });

    group('when docId is not provided', () {
      test('should return a new document', () async {
        final secondDocId = await testCollection.create(value: defaultUser);

        expect(originalDocId, isNot(secondDocId));
      });

      test('should create a new document with the values provided', () async {
        final newUser = TestUser('overwrittenUser');
        final createdDocId = await testCollection.create(value: newUser);

        final updatedUser = await testCollection.read(createdDocId);

        expect(updatedUser, newUser);
      });
    });
  });

  group('#delete', () {
    late DocumentId defaultDocId;

    setUp(() async {
      defaultDocId = await testCollection.create(value: defaultUser);
    });

    test('should remove the document', () async {
      await testCollection.delete(defaultDocId);

      final readResult = await testCollection.read(defaultDocId);

      expect(readResult, isNull);
    });
  });

  group('#getOrCreate', () {
    final documentId = DocumentId('testName');

    test('should create the doc when it does not exist', () async {
      final result = await testCollection.getOrCreate(
          docId: documentId, createValue: defaultUser);

      expect(result, defaultUser);
    });

    test('should get doc when it exists', () async {
      final docId = await testCollection.create(value: defaultUser);

      final testUser = await testCollection.getOrCreate(
          docId: docId, createValue: defaultUser);

      expect(docId.docId, testUser.docId);
    });
  });

  group('#listen', () {
    late Stream<TestUser?> stream;
    late DocumentId docId;

    setUp(() async {
      docId = await testCollection.create(value: defaultUser);

      stream = testCollection.listen(testCollection.collectionRef, docId);
    });

    test('should output new value when doc updates', () async {
      final newUser1 = TestUser('newUser1');
      final newUser2 = TestUser('newUser2');
      final newUser3 = TestUser('newUser3');

      expect(stream, emitsInOrder([newUser1, newUser2, newUser3]));

      await testCollection.update(docId: docId, value: newUser1.toJson());
      await testCollection.update(docId: docId, value: newUser2.toJson());
      await testCollection.update(docId: docId, value: newUser3.toJson());
    });

    test('should output null when doc no longer exists', () async {
      final newUser = TestUser('newUser');

      expect(stream, emitsInOrder([newUser, null]));

      await testCollection.update(docId: docId, value: newUser.toJson());
      await testCollection.delete(docId);
    });
  });

  group('#listenAll', () {
    late Stream<List<TestUser>> stream;
    late DocumentId docId;
    final newUser1 = TestUser('newUser1');
    final newUser2 = TestUser('newUser2');

    setUp(() async {
      docId = await testCollection.create(value: defaultUser);
      await testCollection.create(value: newUser1);

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

      await testCollection.create(value: newUser2);
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
      final docId = await testCollection.create(value: defaultUser);

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
      docId = await testCollection.create(value: defaultUser);

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
        value: updatedUser.toJson(),
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

  group('#update', () {
    test('should fail silently when document does not exist', () async {
      final updateResult = await testCollection.update(
        docId: DocumentId('dodoBird'),
        value: TestUser('Clark Kent').toJson(),
      );

      expect(updateResult, isNull);
    });

    test('should overwrite existing fields', () async {
      final updatedDoc = TestUser('updateValue');
      final docId = await testCollection.create(value: defaultUser);

      await testCollection.update(
        docId: docId,
        value: updatedDoc.toJson(),
      );

      final readResult = await testCollection.read(docId);

      expect(readResult, updatedDoc);
    });

    test('should add new fields', () async {
      const newField = 'newField';
      final updatedDoc = TestUser('updateValue');
      final updatedRawJson = updatedDoc.toJson()
        ..addAll({newField: 'fieldValue'});
      final docId = await testCollection.create(value: defaultUser);

      await testCollection.update(
        docId: docId,
        value: updatedRawJson,
      );

      // Manually get the json from the collection because the new field won't
      //be parsed into the [TestUser] object since we didn't update the
      //[TestUser.fromJson] factory
      final docSnapshot = await instance
          .collection(_testUsersCollectionName)
          .doc(docId.docId)
          .get();

      expect(docSnapshot.data(), updatedRawJson);
    });
  });
}

class TestCollection extends FirefuelCollection<TestUser> {
  TestCollection(this.instance) : super(_testUsersCollectionName);

  final FirebaseFirestore instance;

  @override
  CollectionReference<TestUser?> get collectionRef =>
      super.untypedCollectionRef(instance).withConverter(
            fromFirestore: (snapshot, _) {
              final data = snapshot.data();
              return data == null
                  ? null
                  : TestUser.fromJson(snapshot.data()!, snapshot.id);
            },
            toFirestore: (model, _) => model?.toJson() ?? <String, Object?>{},
          );

  @override
  Stream<List<TestUser>> get stream => listenAll(collectionRef);
}