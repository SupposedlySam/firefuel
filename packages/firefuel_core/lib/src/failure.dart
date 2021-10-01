import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:stack_trace/stack_trace.dart';

abstract class Failure extends Equatable {
  final Object error;
  final Chain stackTrace;

  Failure(this.error, {required this.stackTrace});

  @override
  List<Object> get props => [error, stackTrace];

  @override
  String toString() {
    return '${error.toString()}\n\n${stackTrace.terse}';
  }
}

abstract class FirefuelFailure extends Failure {
  FirefuelFailure({required Object error, required Chain stackTrace})
      : super(error, stackTrace: stackTrace) {
    final isTesting = Platform.environment.containsKey('FLUTTER_TEST');

    if (!isTesting) {
      print(toString()); // coverage:ignore-line
    }
  }
}
