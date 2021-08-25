import 'package:firefuel_core/firefuel_core.dart';
import 'package:stack_trace/stack_trace.dart';

class FirestoreFailure extends FirefuelFailure {
  FirestoreFailure({
    required Object error,
    required Chain stackTrace,
  }) : super(error: error, stackTrace: stackTrace);
}
