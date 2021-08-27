class MissingValueException implements Exception {
  final Type type;

  MissingValueException(this.type);

  @override
  String toString() {
    return '$MissingValueException:$type';
  }
}
