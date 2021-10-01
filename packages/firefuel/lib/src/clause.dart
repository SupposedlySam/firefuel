import 'package:equatable/equatable.dart';

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
class Clause extends Equatable {
  final String field;

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
  final bool isRangeComparison;
  final bool isEqualityOrInComparison;

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
  })  : isRangeComparison = _hasAny([
          isLessThan,
          isLessThanOrEqualTo,
          isGreaterThan,
          isGreaterThanOrEqualTo,
        ]),
        isEqualityOrInComparison = _hasAny(
          [
            isEqualTo,
            whereIn,
            isNull,
          ],
        ) {
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

  // coverage:ignore-start
  @override
  List<Object?> get props => [
        field,
        if (isEqualTo != null) isEqualTo,
        if (isNotEqualTo != null) isNotEqualTo,
        if (isLessThan != null) isLessThan,
        if (isLessThanOrEqualTo != null) isLessThanOrEqualTo,
        if (isGreaterThan != null) isGreaterThan,
        if (isGreaterThanOrEqualTo != null) isGreaterThanOrEqualTo,
        if (arrayContains != null) arrayContains,
        if (arrayContainsAny != null) arrayContainsAny,
        if (whereIn != null) whereIn,
        if (whereNotIn != null) whereNotIn,
        if (isNull != null) isNull,
      ];
  // coverage:ignore-end

  /// Checks for non-null options and throws a [TooManyArgumentsException] when
  /// more than one option is provided
  void _ensureSingleOptionChosen(List<dynamic> options) {
    final providedOptionLength = options.where((e) => e != null).length;
    if (providedOptionLength == 1) return;

    throw TooManyArgumentsException();
  }

  /// Get a subset of the given clauses that are either equality or in
  /// (contains) comparisons
  static List<String> getEqualityOrInComparisonFields(
    List<Clause> clauses,
  ) {
    return clauses
        .where((clause) => clause.isEqualityOrInComparison)
        .map((clause) => clause.field)
        .toList();
  }

  /// Checks to see whether any of the clauses given are equality or in
  /// (contains) comparisons
  static bool hasEqualityOrInComparison(List<Clause> clauses) {
    return clauses.any((clause) => clause.isEqualityOrInComparison);
  }

  /// Checks to see if more than one field is found between all range
  /// comparisons
  static bool hasMoreThanOneFieldInRangeComparisons(List<Clause> clauses) {
    final rangeClauses = clauses.where((clause) => clause.isRangeComparison);
    final uniqueFields = rangeClauses.map((clause) => clause.field).toSet();

    return uniqueFields.length > 1;
  }

  /// Checks to see whether any of the clauses given are range comparisons
  static bool hasRangeComparison(List<Clause> clauses) {
    return clauses.any((clause) => clause.isRangeComparison);
  }

  static bool _hasAny(List<dynamic> options) {
    return options.any((option) => option != null);
  }
}
