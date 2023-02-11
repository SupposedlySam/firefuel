class MissingValueException implements Exception {

  MissingValueException(this.type);
  final Type type;

  @override
  String toString() {
    return '$MissingValueException:$type';
  }
}

class TooManyArgumentsException implements Exception {}

/// Firestore does not support Queries with range filters on different fields
class MoreThanOneFieldInRangeClauseException implements Exception {}
