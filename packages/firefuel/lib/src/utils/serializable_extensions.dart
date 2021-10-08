import 'package:firefuel/firefuel.dart';

extension SerializableX on Serializable {
  Map<String, dynamic> getReplacement(List<String> fieldPaths) {
    final paths =
        fieldPaths.map((field) => FieldPath.fromString(field)).toList();
    final replacement = toJson()
      ..removeWhere((key, _) => !paths.contains(FieldPath.fromString(key)));

    return replacement;
  }
}
