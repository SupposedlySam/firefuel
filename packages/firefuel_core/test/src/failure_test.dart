import 'package:firefuel_core/firefuel_core.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

void main() {
  group('$Failure', () {
    late Failure failure;
    late Object error;
    late Chain chain;

    setUp(() {
      try {
        throw Exception('test message');
      } on Exception catch (e, trace) {
        error = e;
        chain = Chain.forTrace(trace);
        failure = TestFailure(e, stackTrace: chain);
      }
    });

    test('should accept an error object and chain', () {
      expect(failure.error, error);
      expect(failure.stackTrace, chain);
    });

    test('should have an error and chain as props', () {
      expect(failure.props, [error, chain]);
    });

    test('#toString should contain the error', () {
      expect(failure.toString(), contains(error.toString()));
    });
  });

  group('$FirefuelFailure', () {
    late Failure failure;

    setUp(() {
      try {
        throw Exception('test message');
      } on Exception catch (e, trace) {
        failure = TestFirefuelFailure(
          error: e,
          stackTrace: Chain.forTrace(trace),
        );
      }
    });

    test('should create an instance', () {
      expect(failure, isNotNull);
    });
  });
}

class TestFailure extends Failure {
  const TestFailure(super.error, {required super.stackTrace});
}

class TestFirefuelFailure extends FirefuelFailure {
  const TestFirefuelFailure({required super.error, required super.stackTrace});
}
