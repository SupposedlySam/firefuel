import 'package:firefuel/firefuel.dart';
import '../mocks/mock_collection.dart';
import '../utils/expected_failure.dart';
import '../utils/repository_test_util.dart';
import '../utils/test_user.dart';

void main() {
  final docId = DocumentId('h34jfhg43fiuy3gv4');
  final defaultUser = TestUser('testUser');

  RepositoryTestUtil.runTests<DocumentId, TestUser>(
    methodName: 'create',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onCreate: () => docId);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onCreate: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) {
      return testRepository.create(defaultUser);
    },
  );

  RepositoryTestUtil.runTests<DocumentId, TestUser>(
    methodName: 'createById',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onCreateById: () => docId);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onCreateById: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) {
      return testRepository.createById(value: defaultUser, docId: docId);
    },
  );

  RepositoryTestUtil.runTests<Null, TestUser>(
    methodName: 'delete',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onDelete: () => null);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onDelete: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) => testRepository.delete(docId),
  );

  RepositoryTestUtil.runStreamTests<TestUser?, TestUser>(
    methodName: 'listen',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onListen: () => Stream.fromIterable(
          [TestUser('streamUser')],
        ),
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onListen: () => throw ExpectedFailure());
    },
    streamCallback: (testRepository) {
      return testRepository.listen(docId);
    },
  );

  RepositoryTestUtil.runStreamTests<List<TestUser>, TestUser>(
    methodName: 'listenAll',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onListenAll: () => Stream.fromIterable([
          [TestUser('streamUser')]
        ]),
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onListenAll: () => throw ExpectedFailure());
    },
    streamCallback: (testRepository) => testRepository.listenAll(),
  );

  RepositoryTestUtil.runTests<TestUser?, TestUser>(
    methodName: 'read',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onRead: () => defaultUser);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onRead: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) => testRepository.read(docId),
  );

  RepositoryTestUtil.runTests<TestUser?, TestUser>(
    methodName: 'readOrCreate',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onRead: () => defaultUser);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onRead: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) => testRepository.read(docId),
  );

  RepositoryTestUtil.runTests<Null, TestUser>(
    methodName: 'replace',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onReplace: () => null);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onReplace: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) => testRepository.replace(
      docId: docId,
      value: TestUser('replacedUser'),
    ),
  );

  RepositoryTestUtil.runTests<Null, TestUser>(
    methodName: 'replaceFields',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onReplaceFields: () => null);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onReplaceFields: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) => testRepository.replaceFields(
      docId: docId,
      value: TestUser('replacedUserField'),
      fieldPaths: [TestUser.fieldName],
    ),
  );

  RepositoryTestUtil.runTests<Null, TestUser>(
    methodName: 'update',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onUpdate: () => null);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onUpdate: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) {
      return testRepository.update(
        docId: docId,
        value: TestUser('updatedUser'),
      );
    },
  );

  RepositoryTestUtil.runTests<TestUser, TestUser>(
    methodName: 'updateOrCreate',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onUpdateOrCreate: () => defaultUser);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(
          onUpdateOrCreate: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) {
      return testRepository.updateOrCreate(
        docId: docId,
        value: TestUser('updatedUser'),
      );
    },
  );
}
