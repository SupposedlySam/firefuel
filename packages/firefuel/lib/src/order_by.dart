import 'package:equatable/equatable.dart';

/// Creates a condition to order your collection
///
/// [field] must be provided and is normally the string representation of the
/// field on your document to match against.
///
/// It's recommended to store field names on your model so you can access them
/// with `MyModel.field<YourField>` where `MyModel` references the class you're
/// serializing your Document into, and `field<YourField>` is the naming
/// convention to follow (don't include the angle brackets).
///
/// An OrderBy clause also filters for existence of the given fields. The
/// result set will not include documents that do not contain the given fields.
class OrderBy extends Equatable {
  final String field;
  final OrderDirection direction;
  final bool byId;

  OrderBy({
    required this.field,
    OrderDirection direction = OrderDirection.asc,
  })  : this.direction = direction.toAscDesc,
        this.byId = false;

  /// Creates a condition to order your collection by document id
  OrderBy.docId([
    OrderDirection direction = OrderDirection.asc,
  ])  : this.field = 'unused',
        this.direction = direction,
        byId = true;

  @override
  List<Object?> get props => [field, direction];

  /// Handle cases when using [OrderBy] with where clauses containing range
  /// comparisons.
  ///
  /// Where clauses with orderBy criteria have special rules if you use any
  /// range comparisons. When a range comparison exists, the first orderBy
  /// field must match the first where clause field.
  ///
  /// ## Use Cases
  ///
  /// ### Missing Field
  ///
  /// If your first where clause field isn't located in the order by clauses at
  /// all, this method creates an order by clause and puts it in the first
  /// position of the order by list.
  ///
  /// ### Correct Field, Wrong Place
  ///
  /// If your first where clause field isn't located in the first position of
  /// the order by list, this method moves the matching order by field to the
  /// first position of the order by list.
  static List<OrderBy>? moveOrCreateMatchingField({
    required String fieldToMatch,
    required List<OrderBy>? orderBy,
    required bool isRangeComparison,
  }) {
    if (orderBy?.isEmpty ?? true) return null;

    if (isRangeComparison) {
      final hasCorrectValueInWrongSpot = orderBy!.any(
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

  /// Handle cases when using [OrderBy] with where clauses containing equality
  /// or in comparisons.
  ///
  /// You cannot order your query by any field included in an equality or in
  /// clause
  static List<OrderBy>? removeEqualtyAndInMatchingFields({
    required List<String> fieldsToMatch,
    required List<OrderBy>? orderBy,
    required bool isEqualityOrInComparison,
  }) {
    if (orderBy?.isEmpty ?? true) return null;

    if (isEqualityOrInComparison) {
      return orderBy!
          .where((orderBy) => !fieldsToMatch.contains((orderBy.field)))
          .toList();
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
