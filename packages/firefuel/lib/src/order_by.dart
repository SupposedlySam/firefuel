/// Creates a condition to order your collection
///
/// [field] must be provided and is normally the string representation of the
/// field on your document to match against.
///
/// It's recommended to store field names on your model so you can access them
/// with `MyModel.field<YourField>` where `MyModel` references the class you're
/// serializing your Document into, and `field<YourField>` is the naming
/// convention to follow (don't include the angle brackets).
class OrderBy {
  final String field;
  final OrderDirection direction;

  OrderBy({
    required this.field,
    OrderDirection direction = OrderDirection.asc,
  }) : this.direction = direction.toAscDesc;

  static List<OrderBy>? moveOrCreateMatchingField({
    required String fieldToMatch,
    required List<OrderBy>? orderBy,
    required bool isRangeComparison,
  }) {
    if (orderBy?.isEmpty ?? true) return null;

    if (isRangeComparison) {
      final hasCorrectValueInWrongSpot = orderBy!.contains(
        (orderBy) => orderBy.field == fieldToMatch,
      );
      final firstOrder = OrderBy(field: fieldToMatch);
      final isMissingCorrectValue = orderBy.first.field != firstOrder.field;

      if (hasCorrectValueInWrongSpot) {
        return _moveToFirst(fieldToMatch, orderBy);
      } else if (isMissingCorrectValue) {
        return [firstOrder, ...orderBy];
      }
    }

    return orderBy;
  }

  static List<OrderBy> _moveToFirst(
    String fieldToMatch,
    List<OrderBy>? orderBy,
  ) {
    final matchingClause = orderBy!.firstWhere(
      (orderBy) => orderBy.field == fieldToMatch,
    );

    final remainingOrderBy = orderBy.where(
      (orderBy) => orderBy != matchingClause,
    );

    return [matchingClause, ...remainingOrderBy];
  }
}

enum OrderDirection {
  asc,
  desc,
  aToZ,
  zToA,
  smallestToLargest,
  largestToSmallest,
  newestToOldest,
  oldestToNewest,
  falseToTrue,
  trueToFalse,
}

extension on OrderDirection {
  OrderDirection get toAscDesc {
    switch (this) {
      case OrderDirection.asc:
      case OrderDirection.aToZ:
      case OrderDirection.smallestToLargest:
      case OrderDirection.newestToOldest:
      case OrderDirection.falseToTrue:
        return OrderDirection.asc;
      case OrderDirection.desc:
      case OrderDirection.zToA:
      case OrderDirection.largestToSmallest:
      case OrderDirection.oldestToNewest:
      case OrderDirection.trueToFalse:
        return OrderDirection.desc;
    }
  }
}
