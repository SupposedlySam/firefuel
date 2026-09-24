import 'package:cloud_firestore/cloud_firestore.dart' show Filter;
import 'package:firefuel/firefuel.dart';

/// Lowers firefuel's filters and order onto a cloud_firestore [Query].
///
/// Internal: `FirefuelQuery.applyTo` calls these, in the order Firestore
/// requires, alongside cursors and limits.
extension QueryX<T> on Query<T> {
  /// Adds every clause as an AND-ed `where`.
  Query<T> filter(List<Clause> clauses) {
    return clauses.fold(this, (result, clause) {
      return switch (clause) {
        final FieldClause clause => result.where(
          clause.field,
          isEqualTo: clause.isEqualTo,
          isNotEqualTo: clause.isNotEqualTo,
          isLessThan: clause.isLessThan,
          isLessThanOrEqualTo: clause.isLessThanOrEqualTo,
          isGreaterThan: clause.isGreaterThan,
          isGreaterThanOrEqualTo: clause.isGreaterThanOrEqualTo,
          arrayContains: clause.arrayContains,
          arrayContainsAny: clause.arrayContainsAny,
          whereIn: clause.whereIn,
          whereNotIn: clause.whereNotIn,
          isNull: clause.isNull,
        ),
        final ClauseGroup group => result.where(_toFilter(group)),
      };
    });
  }

  /// Adds every [OrderBy], first entry first.
  Query<T> sort(List<OrderBy> orderBy) {
    return orderBy.fold(this, (result, orderBy) {
      return result.orderBy(
        orderBy.byId ? FieldPath.documentId : orderBy.field,
        descending: orderBy.isDescending,
      );
    });
  }
}

/// The cloud_firestore [Filter] for any [Clause].
Filter _toFilter(Clause clause) => switch (clause) {
  FieldClause() => Filter(
    clause.field,
    isEqualTo: clause.isEqualTo,
    isNotEqualTo: clause.isNotEqualTo,
    isLessThan: clause.isLessThan,
    isLessThanOrEqualTo: clause.isLessThanOrEqualTo,
    isGreaterThan: clause.isGreaterThan,
    isGreaterThanOrEqualTo: clause.isGreaterThanOrEqualTo,
    arrayContains: clause.arrayContains,
    arrayContainsAny: clause.arrayContainsAny,
    whereIn: clause.whereIn,
    whereNotIn: clause.whereNotIn,
    isNull: clause.isNull,
  ),
  ClauseGroup(clauses: [final only]) => _toFilter(only),
  ClauseGroup(:final clauses, :final isOr) =>
    Function.apply(
          // Filter.or and Filter.and take 2 to 30 positional filters, not
          // a list.
          isOr ? Filter.or : Filter.and,
          clauses.map(_toFilter).toList(),
        )
        as Filter,
};
