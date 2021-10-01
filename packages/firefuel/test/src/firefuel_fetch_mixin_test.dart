import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';

void main() {
  late TestFetchMixin testFetchMixin;

  setUp(() {
    testFetchMixin = TestFetchMixin();
  });

  group('#guard', () {
    test('should return Right on success', () async {
      final result = await testFetchMixin.guard(() => 'successValue!');

      expect(result, isA<Right<Failure, String>>());
    });

    test('should return Left on failure', () async {
      final result = await testFetchMixin.guard<String>(
        () => throw FormatException(),
      );

      expect(result, isA<Left<Failure, String>>());
    });

    test('should return $FirestoreFailure on failure', () async {
      final result = await testFetchMixin.guard<String>(
        () => throw FormatException('some output'),
      );

      expect(result.getLeft(), isA<FirestoreFailure>());
    });
  });

  group('#guardStream', () {
    test('should return Right on success', () async {
      final result = await testFetchMixin.guardStream(
        () => Stream.fromIterable(['successValue!']),
      );

      expect(await result.first, isA<Right<Failure, String>>());
    });

    test('should return Left on failure', () async {
      final result = await testFetchMixin.guardStream<String>(
        () => throw FormatException(),
      );

      expect(await result.first, isA<Left<Failure, String>>());
    });

    test('should return $FirestoreFailure on failure', () async {
      final result = await testFetchMixin.guardStream<String>(
        () => throw FormatException('some output'),
      );

      final first = await result.first;

      expect(first.getLeft(), isA<FirestoreFailure>());
    });
  });
}

class TestFetchMixin with FirefuelFetchMixin {}
