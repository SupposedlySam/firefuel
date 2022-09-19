import 'package:equatable/equatable.dart';

import 'package:firefuel/firefuel.dart';

class TestUser extends Serializable with EquatableMixin {
  static const String fieldName = 'name',
      fieldAge = 'age',
      fieldOccupation = 'occupation';

  const TestUser(this.name, {this.docId, this.age, this.occupation});

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

  factory TestUser.fromJson(Map<String, dynamic> json, String docId) {
    return TestUser(
      json[fieldName],
      age: json[fieldAge],
      docId: docId,
      occupation: json[fieldOccupation],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {fieldName: name, fieldAge: age, fieldOccupation: occupation};
  }
}
