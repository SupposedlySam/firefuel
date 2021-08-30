import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mock_collection.dart';
import '../../utils/test_repository.dart';

typedef RepoMethodCallback<T> = Future<Either<Failure, T>> Function(
    MockCollection, TestRepository);

class RepositoryTestUtil {
  static void runTests<T extends Serializable>({
    required String methodName,
    required MockCollection mockCollection,
    required RepoMethodCallback<T> onHappyPath,
    required RepoMethodCallback<T> onSadPath,
  }) {
    final testRepository = TestRepository(collection: mockCollection);

    group('#$methodName', () {
      test('should return Right when successful', () async {
        final createResult = await onHappyPath(mockCollection, testRepository);

        expect(createResult, isA<Right<Failure, DocumentId>>());
      });

      test('should return Left when not successful', () async {
        final createResult = await onSadPath(mockCollection, testRepository);

        expect(createResult, isA<Left<Failure, DocumentId>>());
      });
    });
  }
}
