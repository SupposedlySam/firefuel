class MissingValueException implements Exception {
  MissingValueException(this.type);
  final Type type;

  @override
  String toString() {
    return '$MissingValueException:$type';
  }
}

class TooManyArgumentsException implements Exception {}

/// No longer thrown.
///
/// Firestore has supported range filters on up to 10 fields in one query
/// since 2024, so firefuel stopped refusing them in 0.5.
@Deprecated(
  'No longer thrown; Firestore allows range filters on several fields',
)
class MoreThanOneFieldInRangeClauseException implements Exception {}
