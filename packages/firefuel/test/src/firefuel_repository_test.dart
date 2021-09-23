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
    methodCallback: (testRepository) => testRepository.create(defaultUser),
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

  RepositoryTestUtil.runTests<List<TestUser>, TestUser>(
    methodName: 'limit',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onLimit: () => [
          TestUser('unexpectedUser1'),
          TestUser('expectedUser'),
          TestUser('expectedUser'),
          TestUser('unexpectedUser2'),
        ],
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onLimit: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) => testRepository.limit(1),
  );

  RepositoryTestUtil.runStreamTests<TestUser?, TestUser>(
    methodName: 'listen',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onListen: () => Stream.fromIterable([TestUser('streamUser')]),
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onListen: () => throw ExpectedFailure());
    },
    streamCallback: (testRepository) => testRepository.listen(docId),
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

  RepositoryTestUtil.runStreamTests<List<TestUser>, TestUser>(
    methodName: 'listenLimited',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onListenLimited: () => Stream.fromIterable([
          [TestUser('streamUser')]
        ]),
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onListenLimited: () => throw ExpectedFailure());
    },
    streamCallback: (testRepository) => testRepository.listenLimited(1),
  );

  RepositoryTestUtil.runStreamTests<List<TestUser>, TestUser>(
    methodName: 'listenOrdered',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onListenOrdered: () => Stream.fromIterable([
          [TestUser('streamUser')]
        ]),
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onListenOrdered: () => throw ExpectedFailure());
    },
    streamCallback: (testRepository) =>
        testRepository.listenOrdered([OrderBy(field: TestUser.fieldName)]),
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

  RepositoryTestUtil.runStreamTests<List<TestUser>, TestUser>(
    methodName: 'listenWhere(orderBy:{value})',
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
        orderBy: [OrderBy(field: TestUser.fieldName)],
      );
    },
  );

  RepositoryTestUtil.runTests<List<TestUser>, TestUser>(
    methodName: 'orderBy(limit:null)',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onOrderBy: () => [
          TestUser('unexpectedUser1'),
          TestUser('expectedUser'),
          TestUser('expectedUser'),
          TestUser('unexpectedUser2'),
        ],
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onOrderBy: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) =>
        testRepository.orderBy([OrderBy(field: TestUser.fieldName)]),
  );

  RepositoryTestUtil.runTests<List<TestUser>, TestUser>(
    methodName: 'orderBy(limit:1)',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(
        onOrderBy: () => [
          TestUser('unexpectedUser1'),
          TestUser('expectedUser'),
          TestUser('expectedUser'),
          TestUser('unexpectedUser2'),
        ],
      );
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onOrderBy: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) =>
        testRepository.orderBy([OrderBy(field: TestUser.fieldName)], limit: 1),
  );

  RepositoryTestUtil.runTests<Chunk<TestUser>, TestUser>(
    methodName: 'paginate',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onPaginate: () {
        return Chunk<TestUser>(orderBy: [
          OrderBy.string(
            field: TestUser.fieldName,
          )
        ]);
      });
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onPaginate: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) {
      return testRepository.paginate(
        Chunk<TestUser>(orderBy: [
          OrderBy.string(
            field: TestUser.fieldName,
          )
        ]),
      );
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

  RepositoryTestUtil.runTests<List<TestUser>, TestUser>(
    methodName: 'readAll',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onReadAll: () => [defaultUser]);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onReadAll: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) => testRepository.readAll(),
  );

  RepositoryTestUtil.runTests<TestUser, TestUser>(
    methodName: 'readOrCreate',
    mockCollection: MockCollection(),
    initHappyPath: (mockCollection) async {
      mockCollection.initialize(onReadOrCreate: () => defaultUser);
    },
    initSadPath: (mockCollection) async {
      mockCollection.initialize(onReadOrCreate: () => throw ExpectedFailure());
    },
    methodCallback: (testRepository) {
      return testRepository.readOrCreate(
        docId: docId,
        createValue: defaultUser,
      );
    },
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

  RepositoryTestUtil.runTests<List<TestUser>, TestUser>(
    methodName: 'where(orderBy:{value})',
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
        orderBy: [OrderBy(field: TestUser.fieldName)],
      );
    },
  );
}
