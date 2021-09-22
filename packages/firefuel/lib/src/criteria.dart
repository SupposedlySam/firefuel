/// Creates a condition to order your collection
///
/// [field] must be provided and is normally the string representation of the
/// field on your document to match against.
///
/// It's recommended to store field names on your model so you can access them
/// with `MyModel.field<YourField>` where `MyModel` references the class you're
/// serializing your Document into, and `field<YourField>` is the naming
/// convention to follow (don't include the angle brackets).
class Criteria {
  final String field;
  final OrderDirection direction;

  Criteria({
    required this.field,
    required this.direction,
  });
}

enum OrderDirection {
  /// Ordered from smallest to largest, false to true, or oldest date to
  /// newest date
  asc,

  /// Ordered from largest to smallest, true to false, or newest date to
  /// oldest date
  desc,
}
