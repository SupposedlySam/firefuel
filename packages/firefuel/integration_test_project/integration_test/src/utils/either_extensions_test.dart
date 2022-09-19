import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../../utils/expected_failure.dart';

void main() {
  group('#getRight', () {
    test('should return Right when Right exists', () {
      final Either<Failure, String> result = Right('testValue');

      final right = result.getRight();

      expect(right, isA<String>());
    });

    test('should throw $MissingValueException when Right does not exist', () {
      final Either<Failure, String> result = Left(ExpectedFailure());

      expect(
        () => result.getRight(),
        throwsA(isA<MissingValueException>()),
      );
    });
  });

  group('#getLeft', () {
    test('should return Left when $Failure exists', () {
      final Either<Failure, String> result = Left(ExpectedFailure());

      final left = result.getLeft();

      expect(left, isA<Failure>());
    });

    test('should throw $MissingValueException when $Failure does not exist',
        () {
      final Either<Failure, String> result = Right('testValue');

      expect(
        () => result.getLeft(),
        throwsA(isA<MissingValueException>()),
      );
    });
  });

  group('#getRightOrElseNull', () {
    test('should return a nullable Right', () {
      final Either<Failure, String> right = Right('testValue');

      final result = right.getRightOrElseNull();

      expect(result, isA<String?>());
    });

    test('should return Right value when Right exists', () {
      final success = 'testValue';
      final Either<Failure, String> right = Right(success);

      final result = right.getRightOrElseNull();

      expect(result, success);
    });

    test('should return null when Right does not exist', () {
      final Either<Failure, String> result = Left(ExpectedFailure());

      final right = result.getRightOrElseNull();

      expect(right, isNull);
    });
  });

  group('#getLeftOrElseNull', () {
    test('should return a nullable $Failure', () {
      final Either<Failure, String> result = Left(ExpectedFailure());

      final left = result.getLeftOrElseNull();

      expect(left, isA<Failure?>());
    });

    test('should return Left when $Failure exists', () {
      final failure = ExpectedFailure();
      final Either<Failure, String> result = Left(failure);

      final left = result.getLeftOrElseNull();

      expect(left, failure);
    });

    test('should return null when $Failure does not exist', () {
      final Either<Failure, String> result = Right('testValue');

      final left = result.getLeftOrElseNull();

      expect(left, isNull);
    });
  });
}
