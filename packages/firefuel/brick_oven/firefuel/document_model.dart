import 'package:equatable/equatable.dart';
import 'package:firefuel/firefuel.dart';

/// The model representing a __DOCUMENT_NAME__pascal Document in the
/// __COLLECTION_NAME__ Collection.
class __DOCUMENT_NAME__pascal extends Serializable with Equatable {
  const __DOCUMENT_NAME__pascal({required this.docId, required this.name, this.createdAt});

  factory __DOCUMENT_NAME__pascal.fromJson(Map<String, dynamic> json, String docId) {
    return __DOCUMENT_NAME__pascal(
      docId: docId,
      name: json[fieldName] as String,
      createdAt: (json[fieldCreatedAt] as Timestamp?)?.toDate(),
    );
  }

  static const String fieldName = 'name';
  static const String fieldCreatedAt = 'createdAt';

  /// The document id, read from the snapshot rather than stored in the
  /// document.
  final String docId;
  final String name;

  /// Set by the server when the document is first written.
  final DateTime? createdAt;

  @override
  List<Object?> get props => [docId, name, createdAt];

  @override
  Map<String, dynamic> toJson() {
    return {
      fieldName: name,
      // A new document gets the server's clock; an existing one keeps its own.
      fieldCreatedAt: createdAt ?? const ServerTimestamp(),
    };
  }
}
