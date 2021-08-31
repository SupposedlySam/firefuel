import 'package:firefuel/firefuel.dart';
import '../mocks/mock_collection.dart';
import '../utils/expected_failure.dart';
import '../utils/test_user.dart';
import 'utils/repository_test_util.dart';

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
      return testRepository.create(value: defaultUser);
    },
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

  RepositoryTestUtil.runStreamTests<TestUser?, TestUser>(
    methodName: 'readAsStream',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onReadAsStream: () => Stream.fromIterable(
          [TestUser('streamUser')],
        ),
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onReadAsStream: () => throw ExpectedFailure());
    },
    streamCallback: (testRepository) {
      return testRepository.readAsStream(docId);
    },
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
}
