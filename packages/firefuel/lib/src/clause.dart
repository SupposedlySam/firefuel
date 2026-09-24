import 'package:equatable/equatable.dart';

import 'package:firefuel/firefuel.dart';

/// A condition documents must meet to be returned.
///
/// Build one with `Clause(field, ...)` for a single field, or combine
/// clauses with [Clause.or] and [Clause.and].
///
/// `field` is normally the string representation of the field on your
/// document to match against.
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
/// ### Either of two conditions
/// ```dart
/// Clause.or([
///   Clause(MyModel.fieldAge, isLessThan: 18),
///   Clause(MyModel.fieldAge, isGreaterThan: 65),
/// ]);
/// ```
///
/// A list of clauses passed to a query means "all of them" (AND), so
/// [Clause.and] is only needed inside an [Clause.or].
///
/// ### Bad - Throws [TooManyArgumentsException]
///
/// ```dart
/// Clause(MyModel.fieldVehicle, isEqualTo: 'Mazda', isNotEqualTo: 'Honda');
/// ```
sealed class Clause extends Equatable {
  /// A condition on one [field]. Give exactly one operator.
  factory Clause(
    String field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) = FieldClause;

  const Clause._();

  /// Matches documents meeting **any** of [clauses].
  ///
  /// Firestore limits a query to 30 disjunctions once it is expanded, and
  /// requires an index covering each branch.
  factory Clause.or(List<Clause> clauses) = ClauseGroup.or;

  /// Matches documents meeting **all** of [clauses]. Only needed inside
  /// [Clause.or]; a list of clauses is already an AND.
  factory Clause.and(List<Clause> clauses) = ClauseGroup.and;

  /// Clauses that are single-field conditions, ignoring groups.
  ///
  /// The orderBy rules below are about top-level field conditions: Firestore
  /// applies them to the fields a query filters on directly.
  static Iterable<FieldClause> _fieldClauses(List<Clause> clauses) {
    return clauses.whereType<FieldClause>();
  }

  /// Get a subset of the given clauses that are either equality or in
  /// (contains) comparisons
  static List<String> getEqualityOrInComparisonFields(List<Clause> clauses) {
    return _fieldClauses(clauses)
        .where((clause) => clause.isEqualityOrInComparison)
        .map((clause) => clause.field)
        .toList();
  }

  /// Checks to see whether any of the clauses given are equality or in
  /// (contains) comparisons
  static bool hasEqualityOrInComparison(List<Clause> clauses) {
    return _fieldClauses(
      clauses,
    ).any((clause) => clause.isEqualityOrInComparison);
  }

  /// Checks to see whether any of the clauses given are range comparisons
  static bool hasRangeComparison(List<Clause> clauses) {
    return _fieldClauses(clauses).any((clause) => clause.isRangeComparison);
  }

  /// Field Firestore uses for "first orderBy must match your range filter."
  ///
  /// This is the first **range** clause's field, not necessarily the first
  /// clause in the list, so callers can list equality filters before range
  /// filters.
  ///
  /// With range filters on several fields, a caller whose first [orderBy]
  /// already names one of them keeps that order: any range field may lead.
  static String? fieldMatchingRangeOrderingRule(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
  }) {
    final fieldClauses = _fieldClauses(clauses);
    final rangeFields = fieldClauses
        .where((c) => c.isRangeComparison)
        .map((c) => c.field)
        .toList();

    if (rangeFields.isEmpty) return fieldClauses.firstOrNull?.field;

    final leadingOrder = orderBy?.firstOrNull;
    if (leadingOrder != null && rangeFields.contains(leadingOrder.field)) {
      return leadingOrder.field;
    }

    return rangeFields.first;
  }
}

/// A condition on a single field. Build with [Clause.new].
final class FieldClause extends Clause {
  FieldClause(
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
  }) : isRangeComparison = _hasAny([
         isLessThan,
         isLessThanOrEqualTo,
         isGreaterThan,
         isGreaterThanOrEqualTo,
       ]),
       // `isNull: false` lowers to `!= null`, an inequality, so only
       // `isNull: true` counts as equality.
       isEqualityOrInComparison = _hasAny([
         isEqualTo,
         whereIn,
         if (isNull ?? false) isNull,
       ]),
       super._() {
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
      isNull,
    ]);
  }
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

  // coverage:ignore-start
  @override
  // Every operator slot, nulls included: a value alone does not say which
  // operator it belongs to, and `age < 18` must not equal `age > 18`.
  List<Object?> get props => [
    FieldClause,
    field,
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
    isNull,
  ];
  // coverage:ignore-end

  /// Checks for non-null options and throws a [TooManyArgumentsException] when
  /// more than one option is provided
  void _ensureSingleOptionChosen(List<dynamic> options) {
    final providedOptionLength = options.where((e) => e != null).length;
    if (providedOptionLength == 1) return;

    throw TooManyArgumentsException();
  }

  static bool _hasAny(List<dynamic> options) {
    return options.any((option) => option != null);
  }
}

/// Clauses combined with OR or AND. Build with [Clause.or] or [Clause.and].
final class ClauseGroup extends Clause {
  ClauseGroup.or(this.clauses) : isOr = true, super._() {
    _ensureNotEmpty();
  }

  ClauseGroup.and(this.clauses) : isOr = false, super._() {
    _ensureNotEmpty();
  }

  /// The combined clauses.
  final List<Clause> clauses;

  /// Whether a document must meet any clause (OR) rather than all (AND).
  final bool isOr;

  void _ensureNotEmpty() {
    if (clauses.isEmpty) {
      throw ArgumentError.value(clauses, 'clauses', 'must not be empty');
    }
    if (clauses.length > 30) {
      // Filter.or/Filter.and take at most 30 filters.
      throw ArgumentError.value(clauses, 'clauses', 'must hold at most 30');
    }
  }

  @override
  List<Object?> get props => [ClauseGroup, isOr, clauses];
}
