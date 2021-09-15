import 'package:firefuel/firefuel.dart';

extension QueryX<T> on Query<T?> {
  Query<T?> filterIfNotNull(List<Clause>? clauses) {
    if (clauses?.isEmpty ?? true) return this;

    return clauses!.fold(this, (result, clause) {
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

  Query<T?> orderIfNotNull(String? field) {
    if (field == null) return this;

    return orderBy(field);
  }

  Query<T?> limitIfNotNull(int? limit) {
    if (limit == null) return this;

    return this.limit(limit);
  }
}
