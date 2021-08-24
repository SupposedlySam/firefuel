import 'package:firefuel/src/data/models/document_id/document_id_serializer.dart';
import 'package:firefuel/src/data/serializable.dart';

class DocumentId extends Serializable {
  static const fieldDocId = 'docId';

  final String docId;

  DocumentId(String unsafeValue)
      : docId = unsafeValue.replaceAll(RegExp(r'[\/\\]'), ''),
        assert(unsafeValue.isNotEmpty);

  factory DocumentId.fromJson(Map<String, dynamic> json) =
      DocumentIdSerializer.fromJson;

  Map<String, dynamic> toJson() => DocumentIdSerializer.toMap(this);

  @override
  List<Object?> get props => [docId];
}
