import 'package:firefuel/src/data/models/models.dart';

class DocumentIdSerializer extends DocumentId {
  DocumentIdSerializer(String uid) : super(uid);

  factory DocumentIdSerializer.fromJson(Map<String, dynamic> json) {
    return DocumentIdSerializer(json[DocumentId.fieldDocId]);
  }

  static Map<String, dynamic> toMap(DocumentId instance) => {
        DocumentId.fieldDocId: instance.docId,
      };
}
