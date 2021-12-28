import 'package:firefuel/firefuel.dart';

extension EitherExtension<T> on Either<Failure, T> {
  T getRight() {
    T? success;

    try {
      fold((_) {}, (right) {
        success = right;
      });
    } catch (_) {}

    if (success == null) throw MissingValueException(runtimeType);

    return success!;
  }

  Failure getLeft() {
    Failure? failure;

    try {
      fold((left) {
        failure = left;
      }, (_) {});
    } catch (_) {}

    if (failure == null) throw MissingValueException(runtimeType);

    return failure!;
  }

  T? getRightOrElseNull() {
    T? result;

    fold((_) {}, (right) {
      return result = right;
    });

    return result;
  }

  Failure? getLeftOrElseNull() {
    Failure? result;

    fold((left) {
      return result = left;
    }, (_) {});

    return result;
  }
}
