import 'package:firefuel_core/src/models/uid/uid_model.dart';

class UIDSerializer extends UID {
  UIDSerializer(String uid) : super(uid);

  factory UIDSerializer.fromJson(Map<String, dynamic> json) {
    return UIDSerializer(json[UID.fieldOriginal]);
  }

  static Map<String, dynamic> toMap(UID instance) => {
        UID.fieldOriginal: instance.uid,
      };
}
