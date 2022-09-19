import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../mocks/mock_collection.dart';
import 'test_repository.dart';

typedef FutureCallback<R, T extends Serializable> = Future<Either<Failure, R>>
    Function(TestRepository<T>);
typedef StreamCallback<R, T extends Serializable> = Stream<Either<Failure, R>>
    Function(TestRepository<T>);
typedef Initializer<T extends Serializable> = void Function(MockCollection<T>);

class RepositoryTestUtil {
  static void runTests<R, T extends Serializable>({
    required String methodName,
    required MockCollection<T> mockCollection,
    required Initializer<T> initHappyPath,
    required Initializer<T> initSadPath,
    required FutureCallback<R, T> methodCallback,
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

  static void runStreamTests<R, T extends Serializable>({
    required String methodName,
    required MockCollection<T> mockCollection,
    required Initializer<T> initHappyPath,
    required Initializer<T> initSadPath,
    required StreamCallback<R, T> streamCallback,
  }) {
    final testRepository = TestRepository(collection: mockCollection);

    group('#$methodName', () {
      test('should return Right when successful', () async {
        initHappyPath(mockCollection);

        final stream = streamCallback(testRepository);

        expect(stream, emitsInOrder([isA<Right<Failure, R>>()]));
      });

      test('should return Left when not successful', () async {
        initSadPath(mockCollection);

        final stream = streamCallback(testRepository);

        expect(stream, emitsInOrder([isA<Left<Failure, R>>()]));
      });
    });
  }
}
