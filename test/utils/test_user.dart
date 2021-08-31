import 'package:equatable/equatable.dart';
import 'package:firefuel/firefuel.dart';

class TestUser extends Serializable with EquatableMixin {
  static const String fieldName = 'name';

  TestUser(this.name, [this.docId]);

  final String name;

  final String? docId;

  @override
  List<Object?> get props => [name];

  factory TestUser.fromJson(Map<String, dynamic> json, String id) {
    return TestUser(json[fieldName], id);
  }

  @override
  Map<String, dynamic> toJson() {
    return {fieldName: name};
  }
}
