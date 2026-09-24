import 'package:firefuel_core/firefuel_core.dart';
import 'package:test/test.dart';

void main() {
  const Either<String, int> failure = Left('boom');
  const Either<String, int> success = Right(2);

  group('$Either', () {
    test('fold should apply the side that holds a value', () {
      expect(failure.fold((l) => 'L:$l', (r) => 'R:$r'), 'L:boom');
      expect(success.fold((l) => 'L:$l', (r) => 'R:$r'), 'R:2');
    });

    test('isLeft and isRight should report the side', () {
      expect(failure.isLeft(), isTrue);
      expect(failure.isRight(), isFalse);
      expect(success.isLeft(), isFalse);
      expect(success.isRight(), isTrue);
    });

    test('map should transform only a Right', () {
      expect(success.map((r) => r * 10), const Right<String, int>(20));
      expect(failure.map((r) => r * 10), const Left<String, int>('boom'));
    });

    test('leftMap should transform only a Left', () {
      expect(failure.leftMap((l) => l.length), const Left<int, int>(4));
      expect(success.leftMap((l) => l.length), const Right<int, int>(2));
    });

    test('flatMap should chain a Right and short-circuit a Left', () {
      Either<String, int> half(int r) =>
          r.isEven ? Right(r ~/ 2) : const Left('odd');

      expect(success.flatMap(half), const Right<String, int>(1));
      expect(
        const Right<String, int>(3).flatMap(half),
        const Left<String, int>('odd'),
      );
      expect(failure.flatMap(half), const Left<String, int>('boom'));
    });

    test('getOrElse should fall back only for a Left', () {
      expect(success.getOrElse(() => -1), 2);
      expect(failure.getOrElse(() => -1), -1);
    });

    test('swap should exchange the sides', () {
      expect(success.swap(), const Left<int, String>(2));
      expect(failure.swap(), const Right<int, String>('boom'));
    });

    test('should support exhaustive pattern matching', () {
      String describe(Either<String, int> either) => switch (either) {
        Left(:final value) => 'failed with $value',
        Right(:final value) => 'got $value',
      };

      expect(describe(failure), 'failed with boom');
      expect(describe(success), 'got 2');
    });

    test('should compare by side and value', () {
      expect(const Right<String, int>(2), const Right<String, int>(2));
      expect(const Right<String, int>(2), isNot(const Right<String, int>(3)));
      expect(
        const Left<String, String>('x'),
        isNot(const Right<String, String>('x')),
      );
      expect(
        const Left<String, int>('x').hashCode,
        const Left<String, int>('x').hashCode,
      );
    });

    test('left and right should build the matching side', () {
      expect(left<String, int>('boom'), failure);
      expect(right<String, int>(2), success);
    });
  });
}
