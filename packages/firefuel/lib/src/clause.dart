import 'package:firefuel/firefuel.dart';

/// Creates a condition to filter your Collection
///
/// [field] must be provided and is normally the string representation of the
/// field on your document to match against.
///
/// It's recommended to store field names on your model so you can access them
/// with `MyModel.field<YourField>` where `MyModel` references the class you're
/// serializing your Document into, and `field<YourField>` is the naming
/// convention to follow (don't include the angle brackets).
///
/// ## Examples
///
/// ### Good
/// ```dart
/// Clause(MyModel.fieldAge, isEqualTo: 23);
/// ```
///
/// ### Bad - Throws [TooManyArgumentsException]
///
/// ```dart
/// Clause(MyModel.fieldVehicle, isEqualTo: 'Mazda', isNotEqualTo: 'Honda');
/// ```
class Clause {
  final Object field;

  final Object? isEqualTo;
  final Object? isNotEqualTo;
  final Object? isLessThan;
  final Object? isLessThanOrEqualTo;
  final Object? isGreaterThan;
  final Object? isGreaterThanOrEqualTo;
  final Object? arrayContains;
  final List<Object?>? arrayContainsAny;
  final List<Object?>? whereIn;
  final List<Object?>? whereNotIn;
  final bool? isNull;
  Clause(
    this.field, {
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  }) {
    _ensureSingleOptionChosen([
      isEqualTo,
      isNotEqualTo,
      isLessThan,
      isLessThanOrEqualTo,
      isGreaterThan,
      isGreaterThanOrEqualTo,
      arrayContains,
      arrayContainsAny,
      whereIn,
      whereNotIn,
      isNull
    ]);
  }

  /// Checks for non-null options and throws a [TooManyArgumentsException] when
  /// more than one option is provided
  void _ensureSingleOptionChosen(List<dynamic> options) {
    final providedOptionLength = options.where((e) => e != null).length;
    if (providedOptionLength == 1) return;

    throw TooManyArgumentsException();
  }
}
