import 'package:firefuel/firefuel.dart';

extension EitherExtension<T> on Either<Failure, T> {
  /// The success value.
  ///
  /// Throws [MissingValueException] for a Left, and for a Right holding
  /// `null`: use [getRightOrElseNull] when null is an expected success.
  T getRight() => switch (this) {
    Right(:final value?) => value,
    _ => throw MissingValueException(runtimeType),
  };

  /// The failure. Throws [MissingValueException] for a Right.
  Failure getLeft() => switch (this) {
    Left(:final value) => value,
    Right() => throw MissingValueException(runtimeType),
  };

  /// The success value, or `null` for a Left.
  T? getRightOrElseNull() => switch (this) {
    Left() => null,
    Right(:final value) => value,
  };

  /// The failure, or `null` for a Right.
  Failure? getLeftOrElseNull() => switch (this) {
    Left(:final value) => value,
    Right() => null,
  };
}
