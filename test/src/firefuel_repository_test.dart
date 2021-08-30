import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

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
    onHappyPath: (mockCollection, testRepository) async {
      mockCollection.initialize(onCreate: () => docId);

      return testRepository.create(value: defaultUser);
    },
    onSadPath: (mockCollection, testRepository) async {
      mockCollection.initialize(onCreate: () => throw ExpectedFailure());

      return testRepository.create(value: defaultUser);
    },
  );

  RepositoryTestUtil.runTests<TestUser?, TestUser>(
    methodName: 'read',
    mockCollection: MockCollection(),
    onHappyPath: (mockCollection, testRepository) async {
      mockCollection.initialize(onRead: () => defaultUser);

      return testRepository.read(docId);
    },
    onSadPath: (mockCollection, testRepository) async {
      mockCollection.initialize(onRead: () => throw ExpectedFailure());

      return testRepository.read(docId);
    },
  );
  group('#readAsStream', () {}, skip: true);
  group('#update', () {}, skip: true);
  group('#delete', () {}, skip: true);
}
