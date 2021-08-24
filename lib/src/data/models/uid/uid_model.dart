import 'package:firefuel/src/data/models/models.dart';
import 'package:firefuel/src/data/models/uid/uid_serializer.dart';

class UID extends DocumentId {
  static const fieldOriginal = 'uid';

  /// Public Key
  final String uid;

  UID(this.uid) : super(uid);

  factory UID.fromJson(Map<String, dynamic> json) = UIDSerializer.fromJson;

  Map<String, dynamic> toJson() => UIDSerializer.toMap(this);

  @override
  List<Object?> get props => [uid];
}
