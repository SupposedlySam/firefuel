import 'package:firefuel/firefuel.dart';

/// Turns firefuel_core's [FieldUpdate] values into cloud_firestore's
/// `FieldValue` sentinels.
///
/// This is the one place that mapping lives. Every write path (collections,
/// batches, typed converters) runs its outgoing data through [lower], so a
/// [FieldUpdate] behaves the same wherever it is written.
abstract final class FieldUpdates {
  /// A copy of [data] with every [FieldUpdate] replaced by its `FieldValue`,
  /// including inside nested maps.
  ///
  /// Lists are left alone: Firestore does not accept transforms inside
  /// arrays, and rejecting them is the server's call to make.
  static Map<String, Object?> lower(Map<String, Object?> data) {
    return data.map((key, value) => MapEntry(key, _lowerValue(value)));
  }

  static Object? _lowerValue(Object? value) => switch (value) {
    Increment(:final by) => FieldValue.increment(by),
    ArrayUnion(:final values) => FieldValue.arrayUnion(values),
    ArrayRemove(:final values) => FieldValue.arrayRemove(values),
    DeleteField() => FieldValue.delete(),
    ServerTimestamp() => FieldValue.serverTimestamp(),
    final Map<String, Object?> nested => lower(nested),
    _ => value,
  };
}
