import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mock_collection.dart';
import '../../utils/test_repository.dart';

typedef RepoMethodCallback<R, T extends Serializable?>
    = Future<Either<Failure, R>> Function(MockCollection<T>, TestRepository<T>);

class RepositoryTestUtil {
  static void runTests<R, T extends Serializable?>({
    required String methodName,
    required MockCollection<T> mockCollection,
    required RepoMethodCallback<R, T> onHappyPath,
    required RepoMethodCallback<R, T> onSadPath,
  }) {
    final testRepository = TestRepository(collection: mockCollection);

    group('#$methodName', () {
      test('should return Right when successful', () async {
        final result = await onHappyPath(mockCollection, testRepository);

        expect(result, isA<Right<Failure, R>>());
      });

      test('should return Left when not successful', () async {
        final result = await onSadPath(mockCollection, testRepository);

        expect(result, isA<Left<Failure, R>>());
      });
    });
  }
}
