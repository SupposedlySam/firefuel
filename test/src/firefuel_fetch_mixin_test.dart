import 'package:firefuel/firefuel.dart';
import 'package:test/test.dart';

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
}

class TestFetchMixin with FirefuelFetchMixin {}
