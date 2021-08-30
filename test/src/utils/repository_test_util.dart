import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/mock_collection.dart';
import '../../utils/test_repository.dart';

typedef MethodCallback<R, T extends Serializable?> = Future<Either<Failure, R>>
    Function(TestRepository<T>);
typedef Initializer<T extends Serializable?> = void Function(MockCollection<T>);

class RepositoryTestUtil {
  static void runTests<R, T extends Serializable?>({
    required String methodName,
    required MockCollection<T> mockCollection,
    required Initializer<T> initHappyPath,
    required Initializer<T> initSadPath,
    required MethodCallback<R, T> methodCallback,
  }) {
    final testRepository = TestRepository(collection: mockCollection);

    group('#$methodName', () {
      test('should return Right when successful', () async {
        initHappyPath(mockCollection);

        final result = await methodCallback(testRepository);

        expect(result, isA<Right<Failure, R>>());
      });

      test('should return Left when not successful', () async {
        initSadPath(mockCollection);

        final result = await methodCallback(testRepository);

        expect(result, isA<Left<Failure, R>>());
      });
    });
  }
}
