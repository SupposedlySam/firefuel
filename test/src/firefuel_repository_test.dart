import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_collection.dart';
import '../utils/expected_failure.dart';
import '../utils/test_user.dart';
import 'utils/repository_test_util.dart';

void main() {
  final defaultUser = TestUser('testUser');

  RepositoryTestUtil.runTests(
    methodName: 'create',
    mockCollection: MockCollection(),
    onHappyPath: (mockCollection, testRepository) async {
      mockCollection.initialize(
          onCreate: () => DocumentId('h34jfhg43fiuy3gv4'));

      return testRepository.create(value: defaultUser);
    },
    onSadPath: (mockCollection, testRepository) async {
      mockCollection.initialize(onCreate: () => throw ExpectedFailure());

      return testRepository.create(value: defaultUser);
    },
  );

  group('#read', () {}, skip: true);
  group('#readAsStream', () {}, skip: true);
  group('#update', () {}, skip: true);
  group('#delete', () {}, skip: true);
}
