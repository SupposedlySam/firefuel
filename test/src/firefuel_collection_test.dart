import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:test/test.dart';

void main() {
  late FirebaseFirestore instance;
  late TestCollection testCollection;

  setUp(() {
    instance = FakeFirebaseFirestore();
    testCollection = TestCollection(instance);
  });

  group('#create', () {
    final originalUser = TestUser('testName');
    late DocumentId originalDocId;

    setUp(() async {
      originalDocId = await testCollection.create(value: originalUser);
    });

    group('when docId is provided', () {
      test('should return the same document', () async {
        final createResult = await testCollection.create(
          value: originalUser,
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
        final secondDocId = await testCollection.create(value: originalUser);

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
    final originalUser = TestUser('testName');
    late DocumentId originalDocId;

    setUp(() async {
      originalDocId = await testCollection.create(value: originalUser);
    });

    test('should remove the document', () async {
      await testCollection.delete(originalDocId);

      final readResult = await testCollection.read(originalDocId);

      expect(readResult, isNull);
    });
  });

  group('#getOrCreate', () {}, skip: true);

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
              return data == null ? null : TestUser.fromJson(snapshot.data()!);
            },
            toFirestore: (model, _) => model?.toJson() ?? <String, Object?>{},
          );

  @override
  Stream<List<TestUser>> get stream => listenAll(collectionRef);
}

class TestUser extends Serializable {
  static const String fieldName = 'name';

  TestUser(this.name);

  final String name;

  @override
  List<Object?> get props => [name];

  factory TestUser.fromJson(Map<String, dynamic> json) {
    return TestUser(json[fieldName]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {fieldName: name};
  }
}
