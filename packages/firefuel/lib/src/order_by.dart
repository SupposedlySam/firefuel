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

  OrderBy.date({
    required this.field,
    OrderByDate orderBy = OrderByDate.newestToOldest,
  }) : direction = orderBy.direction;

  OrderBy.bool({
    required this.field,
    OrderByBool orderBy = OrderByBool.trueToFalse,
  }) : direction = orderBy.direction;

  OrderBy.num({
    required this.field,
    OrderByNum orderBy = OrderByNum.smallestToLargest,
  }) : direction = orderBy.direction;

  OrderBy.string({
    required this.field,
    OrderByString orderBy = OrderByString.aToZ,
  }) : direction = orderBy.direction;
}

enum OrderDirection { asc, desc }

enum OrderByString { aToZ, zToA }

enum OrderByNum { smallestToLargest, largestToSmallest }

enum OrderByDate { newestToOldest, oldestToNewest }

enum OrderByBool { falseToTrue, trueToFalse }

extension on OrderByString {
  OrderDirection get direction {
    switch (this) {
      case OrderByString.aToZ:
        return OrderDirection.asc;
      case OrderByString.zToA:
        return OrderDirection.desc;
    }
  }
}

extension on OrderByNum {
  OrderDirection get direction {
    switch (this) {
      case OrderByNum.smallestToLargest:
        return OrderDirection.asc;
      case OrderByNum.largestToSmallest:
        return OrderDirection.desc;
    }
  }
}

extension on OrderByDate {
  OrderDirection get direction {
    switch (this) {
      case OrderByDate.newestToOldest:
        return OrderDirection.asc;
      case OrderByDate.oldestToNewest:
        return OrderDirection.desc;
    }
  }
}

extension on OrderByBool {
  OrderDirection get direction {
    switch (this) {
      case OrderByBool.falseToTrue:
        return OrderDirection.asc;
      case OrderByBool.trueToFalse:
        return OrderDirection.desc;
    }
  }
}
