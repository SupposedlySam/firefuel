import 'package:firefuel_core/firefuel_core.dart';

class DocumentIdSerializer extends DocumentId {
  DocumentIdSerializer(super.unsafeValue);

  factory DocumentIdSerializer.fromJson(Map<String, dynamic> json) {
    return DocumentIdSerializer(json[DocumentId.fieldDocId] as String);
  }

  static Map<String, dynamic> toMap(DocumentId instance) => {
    DocumentId.fieldDocId: instance.docId,
  };
}
