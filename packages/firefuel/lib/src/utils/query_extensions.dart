import 'package:firefuel/firefuel.dart';

extension QueryX<T> on Query<T?> {
  Query<T?> filterIfNotNull(List<Clause>? clauses) {
    if (clauses == null) return this;

    return filter(clauses);
  }

  Query<T?> filter(List<Clause> clauses) {
    if (clauses.isEmpty) return this;

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
        whereIn: clause.whereIn,
        whereNotIn: clause.whereNotIn,
        isNull: clause.isNull,
      );
    });
  }

  Query<T?> startAfterIfNotNull(DocumentSnapshot<T?>? cursor) {
    if (cursor == null) return this;

    return startAfterDocument(cursor);
  }

  Query<T?> sortIfNotNull(List<OrderBy>? orderBy) {
    if (orderBy == null) return this;

    return sort(orderBy);
  }

  Query<T?> sort(List<OrderBy> orderBy) {
    if (orderBy.isEmpty) return this;

    return orderBy.fold(this, (result, orderBy) {
      return result.orderBy(
        orderBy.byId ? FieldPath.documentId : orderBy.field,
        descending: orderBy.direction == OrderDirection.desc,
      );
    });
  }

  Query<T?> limitIfNotNull(int? limit) {
    if (limit == null) return this;

    return this.limit(limit);
  }
}
