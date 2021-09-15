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

  RepositoryTestUtil.runStreamTests<List<TestUser>, TestUser>(
    methodName: 'listen',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onListen: () => Stream.fromIterable([TestUser('streamUser')]),
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onListenLimited: () => throw ExpectedFailure());
    },
    streamCallback: (testRepository) {
      return testRepository.listenLimited(1);
    },
  );

  RepositoryTestUtil.runStreamTests<TestUser?, TestUser>(
    methodName: 'listenLimited',
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
    methodName: 'listenWhere(limit:null)',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onListenWhere: () => Stream.fromIterable(
          [
            [
              TestUser('unexpectedUser1'),
              TestUser('expectedUser'),
              TestUser('unexpectedUser2'),
            ]
          ],
        ),
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onListenWhere: () => throw ExpectedFailure());
    },
    streamCallback: (testRepository) {
      return testRepository.listenWhere([
        Clause(TestUser.fieldName, isEqualTo: 'expectedUser'),
      ]);
    },
  );

  RepositoryTestUtil.runStreamTests<List<TestUser>, TestUser>(
    methodName: 'listenWhere(limit:1)',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onListenWhere: () => Stream.fromIterable(
          [
            [
              TestUser('unexpectedUser1'),
              TestUser('expectedUser'),
              TestUser('expectedUser'),
              TestUser('unexpectedUser2'),
            ]
          ],
        ),
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onListenWhere: () => throw ExpectedFailure());
    },
    streamCallback: (testRepository) {
      return testRepository.listenWhere(
        [Clause(TestUser.fieldName, isEqualTo: 'expectedUser')],
        limit: 1,
      );
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

  RepositoryTestUtil.runTests<List<TestUser>, TestUser>(
    methodName: 'where(limit:null)',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onWhere: () => [
          TestUser('unexpectedUser1'),
          TestUser('expectedUser'),
          TestUser('unexpectedUser2'),
        ],
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onWhere: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) {
      return testRepository.where([
        Clause(TestUser.fieldName, isEqualTo: 'expectedUser'),
      ]);
    },
  );

  RepositoryTestUtil.runTests<List<TestUser>, TestUser>(
    methodName: 'where(limit:1)',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onWhere: () => [
          TestUser('unexpectedUser1'),
          TestUser('expectedUser'),
          TestUser('expectedUser'),
          TestUser('unexpectedUser2'),
        ],
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onWhere: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) {
      return testRepository.where(
        [Clause(TestUser.fieldName, isEqualTo: 'expectedUser')],
        limit: 1,
      );
    },
  );
}
