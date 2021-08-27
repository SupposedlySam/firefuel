import 'package:dartz/dartz.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/expected_failure.dart';

void main() {
  group('#getOrElseNull', () {
    test('should return a nullable T', () {
      final Either<Failure, String> right = Right('testValue');

      final result = right.getOrElseNull();

      expect(result, isA<String?>());
    });

    test('should return right when right is provided', () {
      final success = 'testValue';
      final Either<Failure, String> right = Right(success);

      final result = right.getOrElseNull();

      expect(result, success);
    });

    test('should return null when left is provided', () {
      final Either<Failure, String> left = Left(ExpectedFailure());

      final result = left.getOrElseNull();

      expect(result, isNull);
    });
  });

  group('#getLeftOrElseNull', () {
    test('should return a nullable $Failure', () {
      final Either<Failure, String> left = Left(ExpectedFailure());

      final result = left.getLeftOrElseNull();

      expect(result, isA<Failure?>());
    });

    test('should return left when left is provided', () {
      final failure = ExpectedFailure();
      final Either<Failure, String> left = Left(failure);

      final result = left.getLeftOrElseNull();

      expect(result, failure);
    });

    test('should return null when right is provided', () {
      final Either<Failure, String> right = Right('testValue');

      final result = right.getLeftOrElseNull();

      expect(result, isNull);
    });
  });
}
