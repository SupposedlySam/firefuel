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
  Future<Either<Failure, R>> guard<R>(
    FutureOr<R> Function() callback,
  ) async {
    try {
      final result = await callback();

      return Right(result);
    } on Object catch (e, stack) {
      if (e is FormatException) {
        // Intentionally using print for debugging format exceptions in
        // development
        // ignore: avoid_print
        print('Format Exception: ${e.message}');
      }

      return Left(
        FirestoreFailure(
          error: e,
          stackTrace: Chain.forTrace(stack),
        ),
      );
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
      if (e is FormatException) {
        // Intentionally using print for debugging format exceptions in
        // development
        // ignore: avoid_print
        print('Format Exception: ${e.message}');
      }

      yield Left(
        FirestoreFailure(
          error: e,
          stackTrace: Chain.forTrace(stack),
        ),
      );
    }
  }
}
