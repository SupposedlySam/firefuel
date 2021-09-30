import 'package:firefuel_core/firefuel_core.dart';

class DocumentIdSerializer extends DocumentId {
  DocumentIdSerializer(String docId) : super(docId);

  factory DocumentIdSerializer.fromJson(Map<String, dynamic> json) {
    return DocumentIdSerializer(json[DocumentId.fieldDocId]);
  }

  static Map<String, dynamic> toMap(DocumentId instance) => {
        DocumentId.fieldDocId: instance.docId,
      };
}
