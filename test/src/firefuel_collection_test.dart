import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:test/test.dart';

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

  group('#listen', () {}, skip: true);

  group('#listenAll', () {}, skip: true);

  group('#read', () {}, skip: true);

  group('#readAsStream', () {}, skip: true);

  group('#update', () {}, skip: true);
}

class TestCollection extends FirefuelCollection<TestUser> {
  TestCollection(this.instance) : super('testUsers');

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

class TestUser extends Serializable {
  static const String fieldName = 'name';

  TestUser(this.name, [this.docId]);

  final String name;

  final String? docId;

  @override
  List<Object?> get props => [name];

  factory TestUser.fromJson(Map<String, dynamic> json, String id) {
    return TestUser(json[fieldName], id);
  }

  @override
  Map<String, dynamic> toJson() {
    return {fieldName: name};
  }
}
