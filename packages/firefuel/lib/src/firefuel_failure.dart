import 'package:firefuel_core/firefuel_core.dart';

class FirestoreFailure extends FirefuelFailure {
  FirestoreFailure({
    required super.error,
    required super.stackTrace,
  });
}
