import 'package:equatable/equatable.dart';

/// A value the database computes when the write lands, instead of a value
/// you send.
///
/// Use one wherever firefuel writes a field: as a value in `updateFields`,
/// or returned from a model's `toJson`, so models that depend only on
/// firefuel_core (with no Flutter or cloud_firestore) can still ask for a
/// server timestamp or an increment. firefuel turns each into the matching
/// `FieldValue` on every write path.
///
/// ```dart
/// await users.updateFields(
///   docId: id,
///   fields: {
///     User.fieldTokens: FieldUpdate.arrayUnion([token]),
///     User.fieldLoginCount: const FieldUpdate.increment(1),
///     User.fieldLastSeen: const FieldUpdate.serverTimestamp(),
///     User.fieldSupportsReactions: true, // a plain value is a plain set
///   },
/// );
/// ```
sealed class FieldUpdate extends Equatable {
  const FieldUpdate();

  /// Adds [by] to the stored number (a missing field counts as 0).
  const factory FieldUpdate.increment(num by) = Increment;

  /// Adds each of [values] the array does not already contain.
  const factory FieldUpdate.arrayUnion(List<Object?> values) = ArrayUnion;

  /// Removes every occurrence of each of [values] from the array.
  const factory FieldUpdate.arrayRemove(List<Object?> values) = ArrayRemove;

  /// Deletes the field. Only valid in updates and merging sets.
  const factory FieldUpdate.delete() = DeleteField;

  /// The server's clock when the write is committed.
  const factory FieldUpdate.serverTimestamp() = ServerTimestamp;

  /// Every variant leads its props with its own type. equatable 3 stopped
  /// comparing `runtimeType`, so without it `DeleteField()` would equal
  /// `ServerTimestamp()` and `ArrayUnion(x)` would equal `ArrayRemove(x)`.
  @override
  List<Object?> get props => [runtimeType, ..._values];

  List<Object?> get _values;
}

/// See [FieldUpdate.increment].
final class Increment extends FieldUpdate {
  const Increment(this.by);

  final num by;

  @override
  List<Object?> get _values => [by];
}

/// See [FieldUpdate.arrayUnion].
final class ArrayUnion extends FieldUpdate {
  const ArrayUnion(this.values);

  final List<Object?> values;

  @override
  List<Object?> get _values => [values];
}

/// See [FieldUpdate.arrayRemove].
final class ArrayRemove extends FieldUpdate {
  const ArrayRemove(this.values);

  final List<Object?> values;

  @override
  List<Object?> get _values => [values];
}

/// See [FieldUpdate.delete].
final class DeleteField extends FieldUpdate {
  const DeleteField();

  @override
  List<Object?> get _values => const [];
}

/// The server's clock when the write is committed.
///
/// Return it from a model's `toJson` for a field the server should stamp,
/// such as `createdAt` on a new document:
///
/// ```dart
/// Map<String, dynamic> toJson() => {
///   fieldText: text,
///   fieldCreatedAt: createdAt ?? const ServerTimestamp(),
/// };
/// ```
///
/// Until the write reaches the server, reads of the local cache see `null`
/// for the field. Read with
/// `GetOptions(serverTimestampBehavior: ServerTimestampBehavior.estimate)`
/// to get the local clock's estimate instead.
final class ServerTimestamp extends FieldUpdate {
  const ServerTimestamp();

  @override
  List<Object?> get _values => const [];
}
