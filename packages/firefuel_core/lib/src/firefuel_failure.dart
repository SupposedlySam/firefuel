import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:stack_trace/stack_trace.dart';

abstract class Failure {}

abstract class FirefuelFailure extends Equatable implements Failure {
  final Object error;
  final Chain stackTrace;

  FirefuelFailure({required this.error, required this.stackTrace}) {
    final isTesting = Platform.environment.containsKey('FLUTTER_TEST');

    if (!isTesting) {
      print(toString());
    }
  }

  @override
  List<Object> get props => [error, stackTrace];

  @override
  String toString() {
    return '${error.toString()}\n\n${stackTrace.terse}';
  }
}
