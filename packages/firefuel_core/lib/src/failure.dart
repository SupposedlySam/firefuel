import 'package:equatable/equatable.dart';
import 'package:stack_trace/stack_trace.dart';

/// The left side of every firefuel `Either`: what went wrong, and where.
///
/// Extend it for your own app failures so repositories can return
/// `Either<Failure, T>` for any error source, not only Firestore.
abstract class Failure extends Equatable {
  const Failure(this.error, {required this.stackTrace});

  /// The error or exception that caused this failure.
  final Object error;

  /// Where [error] was raised, folded across async gaps.
  final Chain stackTrace;

  @override
  List<Object> get props => [error, stackTrace];

  @override
  String toString() => '$error\n\n${stackTrace.terse}';
}

/// A [Failure] raised by firefuel itself.
///
/// Constructing one has no side effects. Earlier versions printed every
/// failure to stdout from this constructor; that could not be turned off,
/// could not be routed to a logger, and was the only reason firefuel_core
/// depended on `universal_io`. Reporting now belongs to the caller that
/// catches the error (see firefuel's `FirefuelFetchMixin`).
abstract class FirefuelFailure extends Failure {
  const FirefuelFailure({required Object error, required Chain stackTrace})
    : super(error, stackTrace: stackTrace);
}
