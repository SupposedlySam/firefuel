import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../../utils/expected_failure.dart';

void main() {
  group('#getRight', () {
    test('should return Right when Right exists', () {
      const Either<Failure, String> result = Right('testValue');

      expect(result.getRight(), 'testValue');
    });

    test('should throw $MissingValueException for a Right holding null', () {
      const Either<Failure, String?> result = Right(null);

      expect(result.getRight, throwsA(isA<MissingValueException>()));
    });

    test('should throw $MissingValueException when Right does not exist', () {
      final Either<Failure, String> result = Left(ExpectedFailure());

      expect(result.getRight, throwsA(isA<MissingValueException>()));
    });
  });

  group('#getLeft', () {
    test('should return Left when $Failure exists', () {
      final failure = ExpectedFailure();
      final Either<Failure, String> result = Left(failure);

      expect(result.getLeft(), same(failure));
    });

    test(
      'should throw $MissingValueException when $Failure does not exist',
      () {
        const Either<Failure, String> result = Right('testValue');

        expect(result.getLeft, throwsA(isA<MissingValueException>()));
      },
    );
  });

  group('#getRightOrElseNull', () {
    test('should return Right value when Right exists', () {
      const success = 'testValue';
      const Either<Failure, String> right = Right(success);

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
    test('should return Left when $Failure exists', () {
      final failure = ExpectedFailure();
      final Either<Failure, String> result = Left(failure);

      final left = result.getLeftOrElseNull();

      expect(left, failure);
    });

    test('should return null when $Failure does not exist', () {
      const Either<Failure, String> result = Right('testValue');

      final left = result.getLeftOrElseNull();

      expect(left, isNull);
    });
  });
}
