import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:firefuel_core/firefuel_core.dart';
import 'package:firefuel_core/src/models/document_id/document_id_serializer.dart';

/// Strips out illegal characters from a string intended to be used as a
/// document ID in Firestore
///
/// Removes all forward slashes from the string by default. Set
/// `throwsOnForwardSlash` if you would prefer for it to throw a
/// [CannotContainForwardSlash] [FormatException] instead.
///
/// Potential to throw [FormatException] of type [CannotBeNoLongerThan1500Bytes],
/// [CannotSolelyConsistOfASingleOrDoublePeriod],
/// [CannotStartAndEndWithDoubleUnderscore], or [CannotContainForwardSlash].
class DocumentId extends Serializable with EquatableMixin {
  static const fieldDocId = 'docId';

  final String docId;

  DocumentId(
    String unsafeValue, {
    throwsOnForwardSlash = false,
  })  : docId = _validateAndReplace(unsafeValue, throwsOnForwardSlash),
        assert(unsafeValue.isNotEmpty);

  static String _validateAndReplace(
    String unsafeValue,
    bool throwsOnForwardSlash,
  ) {
    _validate(unsafeValue, throwsOnForwardSlash);

    return unsafeValue.replaceAll(RegExp(r'/'), '');
  }

  /// Verifies the string is a valid Firestore document ID
  ///
  /// ### Requirements
  /// - Must be valid UTF-8 characters
  /// - Must be no longer than 1,500 bytes
  /// - Cannot contain a forward slash (/)
  /// - Cannot solely consist of a single period (.) or double periods (..)
  /// - Cannot match the regular expression __.*__
  ///
  ///  Source: https://firebase.google.com/docs/firestore/quotas#limits
  static void _validate(String unsafeValue, bool throwsOnForwardSlash) {
    final RegExp singleOrDoublePeriod = RegExp(r'^(\.*\.+)$'),
        underscores = RegExp(r'__.*__'),
        forwardSlash = RegExp(r'/');

    final bytes = utf8.encode(unsafeValue);
    if (bytes.length > 1500) {
      throw CannotBeNoLongerThan1500Bytes();
    }

    if (singleOrDoublePeriod.hasMatch(unsafeValue)) {
      throw CannotSolelyConsistOfASingleOrDoublePeriod();
    }

    if (underscores.hasMatch(unsafeValue)) {
      throw CannotStartAndEndWithDoubleUnderscore();
    }

    if (throwsOnForwardSlash && forwardSlash.hasMatch(unsafeValue)) {
      throw CannotContainForwardSlash();
    }
  }

  factory DocumentId.fromJson(Map<String, dynamic> json) =
      DocumentIdSerializer.fromJson;

  Map<String, dynamic> toJson() => DocumentIdSerializer.toMap(this);

  @override
  List<Object?> get props => [docId];
}
