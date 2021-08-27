import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firefuel/firefuel.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:firefuel_core/firefuel_core.dart';

mixin FirefuelFetchMixin {
  Future<Either<Failure, R>> guard<R>(
    FutureOr<R> Function() callback,
  ) async {
    try {
      final result = await callback();

      return Right(result);
    } catch (e) {
      if (e is FormatException) {
        print('Format Exception: ${e.message}');
      }

      return Left(
        FirestoreFailure(
          error: e,
          stackTrace: Chain.current(),
        ),
      );
    }
  }
}