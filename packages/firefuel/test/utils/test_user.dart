import 'package:equatable/equatable.dart';

import 'package:firefuel/firefuel.dart';

class TestUser extends Serializable with EquatableMixin {
  const TestUser(this.name, {this.docId, this.age, this.occupation});

  factory TestUser.fromJson(Map<String, dynamic> json, String docId) {
    return TestUser(
      json[fieldName] as String,
      age: json[fieldAge] as int?,
      docId: docId,
      occupation: json[fieldOccupation] as String?,
    );
  }
  static const String fieldName = 'name';
  static const String fieldAge = 'age';
  static const String fieldOccupation = 'occupation';

  final String name;
  final int? age;
  final String? docId;
  final String? occupation;

  @override
  List<Object?> get props => [
        name,
        if (age != null) age,
        if (occupation != null) occupation,
      ];

  @override
  Map<String, dynamic> toJson() {
    return {fieldName: name, fieldAge: age, fieldOccupation: occupation};
  }
}
