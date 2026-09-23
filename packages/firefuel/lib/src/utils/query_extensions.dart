import 'package:firefuel/firefuel.dart';

/// Lowers firefuel's filters and order onto a cloud_firestore [Query].
///
/// Internal: `FirefuelQuery.applyTo` calls these, in the order Firestore
/// requires, alongside cursors and limits.
extension QueryX<T> on Query<T> {
  /// Adds every clause as an AND-ed `where`.
  Query<T> filter(List<Clause> clauses) {
    return clauses.fold(this, (result, clause) {
      return result.where(
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
      );
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
