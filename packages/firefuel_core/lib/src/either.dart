import 'package:meta/meta.dart';

/// A value that is either a [Left] (by convention a failure) or a [Right]
/// (by convention a success).
///
/// Firefuel repositories return `Either<Failure, T>` so callers must handle
/// both outcomes. Unwrap it with [fold], or with a `switch`:
///
/// ```dart
/// final message = switch (await repository.read(id)) {
///   Left(:final value) => 'failed: ${value.error}',
///   Right(:final value) => 'read ${value?.name}',
/// };
/// ```
///
/// Until 0.5 firefuel re-exported `Either` from `package:dartz`, which has
/// not been released since 2021. The names and the methods firefuel users
/// relied on (`fold`, `map`, `isLeft`, `isRight`, `getOrElse`, `swap`, and
/// the `left()`/`right()` constructors) are kept, so migrating means
/// replacing `package:dartz` imports only.
@immutable
sealed class Either<L, R> {
  const Either();

  /// Applies [ifLeft] or [ifRight], whichever side holds a value.
  B fold<B>(B Function(L value) ifLeft, B Function(R value) ifRight);

  /// Whether this is a [Left].
  bool isLeft() => this is Left<L, R>;

  /// Whether this is a [Right].
  bool isRight() => this is Right<L, R>;

  /// Transforms the [Right] value, passing a [Left] through unchanged.
  Either<L, R2> map<R2>(R2 Function(R value) f) => switch (this) {
    Left(:final value) => Left(value),
    Right(:final value) => Right(f(value)),
  };

  /// Transforms the [Left] value, passing a [Right] through unchanged.
  Either<L2, R> leftMap<L2>(L2 Function(L value) f) => switch (this) {
    Left(:final value) => Left(f(value)),
    Right(:final value) => Right(value),
  };

  /// Chains a computation that can itself fail onto the [Right] value.
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R value) f) =>
      switch (this) {
        Left(:final value) => Left(value),
        Right(:final value) => f(value),
      };

  /// The [Right] value, or [orElse]'s result for a [Left].
  R getOrElse(R Function() orElse) => switch (this) {
    Left() => orElse(),
    Right(:final value) => value,
  };

  /// Exchanges the two sides.
  Either<R, L> swap() => switch (this) {
    Left(:final value) => Right(value),
    Right(:final value) => Left(value),
  };
}

/// The failure side of an [Either].
final class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  B fold<B>(B Function(L value) ifLeft, B Function(R value) ifRight) =>
      ifLeft(value);

  @override
  bool operator ==(Object other) => other is Left && other.value == value;

  @override
  int get hashCode => Object.hash(Left, value);

  @override
  String toString() => 'Left($value)';
}

/// The success side of an [Either].
final class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  B fold<B>(B Function(L value) ifLeft, B Function(R value) ifRight) =>
      ifRight(value);

  @override
  bool operator ==(Object other) => other is Right && other.value == value;

  @override
  int get hashCode => Object.hash(Right, value);

  @override
  String toString() => 'Right($value)';
}

/// Creates a [Left], for when a type argument reads better than a class.
Either<L, R> left<L, R>(L value) => Left(value);

/// Creates a [Right], for when a type argument reads better than a class.
Either<L, R> right<L, R>(R value) => Right(value);
