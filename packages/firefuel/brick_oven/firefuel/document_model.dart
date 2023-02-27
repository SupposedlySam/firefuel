import 'package:equatable/equatable.dart';
import 'package:firefuel/firefuel.dart';

/// The model representing a __DOCUMENT_NAME__pascal Document in the
/// __DOCUMENT_NAME__pascal Collection.
class __DOCUMENT_NAME__pascal extends Serializable with EquatableMixin {
  const User({
    required this.docId,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json, String docId) {
    return User(
      docId: docId,
      username: json[fieldUsername] as String,
    );
  }

  static const String fieldDocId = 'docId';
  static const String fieldUsername = 'username';

  final String docId;
  final String username;

  @override
  List<Object?> get props => [docId, username];

  @override
  Map<String, dynamic> toJson() {
    return {
      fieldDocId: docId, // optionally add this to your document
      fieldUsername: username,
    };
  }
}
