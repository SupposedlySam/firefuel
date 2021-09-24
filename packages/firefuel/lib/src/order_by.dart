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
