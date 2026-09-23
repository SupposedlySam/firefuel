class MissingValueException implements Exception {
  MissingValueException(this.type);
  final Type type;

  @override
  String toString() {
    return '$MissingValueException:$type';
  }
}

class TooManyArgumentsException implements Exception {}
