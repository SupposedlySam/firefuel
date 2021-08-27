import 'dart:convert';

import 'package:firefuel_core/src/models/uid/uid_model.dart';
import 'package:firefuel_core/src/models/uid/uid_serializer.dart';
import 'package:test/test.dart';

void main() {
  const uidValue = 'someTestValue',
      rawJson = """
    {
      "${UID.fieldOriginal}" : "$uidValue"
    }
    """;

  test('#fromJson should convert correctly', () {
    final uid = UIDSerializer.fromJson(json.decode(rawJson));

    expect(uid, isA<UID>());
  });

  test('.toMap should convert correctly', () {
    final instance = UIDSerializer(uidValue);
    final result = UIDSerializer.toMap(instance);

    expect(result, json.decode(rawJson));
  });
}
