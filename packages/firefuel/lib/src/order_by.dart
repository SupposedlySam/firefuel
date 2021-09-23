import 'package:firefuel/firefuel.dart';

/// Creates a condition to order your collection
///
/// [path] must be provided and is normally the string representation of the
/// field on your document to match against.
///
/// It's recommended to store field names on your model so you can access them
/// with `MyModel.field<YourField>` where `MyModel` references the class you're
/// serializing your Document into, and `field<YourField>` is the naming
/// convention to follow (don't include the angle brackets).
class OrderBy {
  final FieldPath path;
  final OrderDirection direction;

  const OrderBy._({
    required this.path,
    required this.direction,
  });

  OrderBy.date({
    required String field,
    OrderByDate orderBy = OrderByDate.newestToOldest,
  })  : direction = orderBy.direction,
        path = FieldPath.fromString(field);

  OrderBy.bool({
    required String field,
    OrderByBool orderBy = OrderByBool.trueToFalse,
  })  : direction = orderBy.direction,
        path = FieldPath.fromString(field);

  OrderBy.num({
    required String field,
    OrderByNum orderBy = OrderByNum.smallestToLargest,
  })  : direction = orderBy.direction,
        path = FieldPath.fromString(field);

  OrderBy.string({
    required String field,
    OrderByString orderBy = OrderByString.aToZ,
  })  : direction = orderBy.direction,
        path = FieldPath.fromString(field);

  OrderBy.fromFieldPath({
    required this.path,
    this.direction = OrderDirection.asc,
  });
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
