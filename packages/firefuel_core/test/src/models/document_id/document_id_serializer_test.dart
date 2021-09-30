import 'dart:convert';

import 'package:test/test.dart';

import 'package:firefuel_core/src/models/document_id/document_id_model.dart';
import 'package:firefuel_core/src/models/document_id/document_id_serializer.dart';

void main() {
  const docIdValue = 'someTestValue',
      rawJson = """
    {
      "${DocumentId.fieldDocId}" : "$docIdValue"
    }
    """;

  test('#fromJson should convert correctly', () {
    final docId = DocumentIdSerializer.fromJson(json.decode(rawJson));

    expect(docId, isA<DocumentId>());
  });

  test('.toMap should convert correctly', () {
    final instance = DocumentIdSerializer(docIdValue);
    final result = DocumentIdSerializer.toMap(instance);

    expect(result, json.decode(rawJson));
  });
}
