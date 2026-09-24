import 'dart:async';

import 'package:stack_trace/stack_trace.dart';

import 'package:firefuel/firefuel.dart';

mixin FirefuelFetchMixin {
  /// Protects the provided function from throwing an unhandled exception
  ///
  /// The left side of the returned [Either] will be a [FirestoreFailure] if any
  /// errors are triggered by the [callback]
  ///
  /// See also: [guardStream] for [Stream] types
  Future<Either<Failure, R>> guard<R>(FutureOr<R> Function() callback) async {
    try {
      final result = await callback();

      return Right(result);
    } on Object catch (e, stack) {
      return Left(report(e, stack));
    }
  }

  /// Protects the provided function from throwing an unhandled exception
  ///
  /// The left side of the returned [Either] will be a [FirestoreFailure] if any
  /// errors are triggered by the [streamCallback]
  ///
  /// See also: [guard] for [Future] types
  Stream<Either<Failure, R>> guardStream<R>(
    Stream<R> Function() streamCallback,
  ) async* {
    try {
      await for (final result in streamCallback()) {
        yield Right(result);
      }
    } on Object catch (e, stack) {
      yield Left(report(e, stack));
    }
  }

  /// Wraps [error] in a [FirestoreFailure] and tells `Firefuel.observer`.
  ///
  /// Use it from your own catch blocks to report the way firefuel does.
  ///
  /// This replaced two things: `FirefuelFailure` printing itself from its
  /// constructor, and a `print` of every `FormatException` here. Neither
  /// could be turned off or routed anywhere.
  static Failure report(Object error, StackTrace stack) {
    final failure = FirestoreFailure(
      error: error,
      stackTrace: Chain.forTrace(stack),
    );
    Firefuel.observer.onFailure(failure);
    return failure;
  }
}
