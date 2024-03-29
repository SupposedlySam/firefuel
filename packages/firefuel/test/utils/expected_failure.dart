import 'package:firefuel_core/firefuel_core.dart';
import 'package:stack_trace/stack_trace.dart';

class ExpectedFailure extends Failure implements Exception {
  ExpectedFailure()
      : super(
          'expected failure',
          stackTrace: Chain.current(),
        );
}
