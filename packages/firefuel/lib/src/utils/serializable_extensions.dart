import 'package:firefuel/firefuel.dart';

extension SerializableX on Serializable {
  /// Creates a JSON object with only the provided fields
  Map<String, dynamic> toIsolatedJson(List<String> fields) {
    return toJson()..removeWhere((key, _) => !fields.contains(key));
  }
}
