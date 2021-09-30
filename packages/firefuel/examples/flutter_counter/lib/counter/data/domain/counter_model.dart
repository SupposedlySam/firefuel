import 'package:firefuel/firefuel.dart';

class Counter extends Serializable {
  const Counter({required this.value, required this.id});

  factory Counter.fromJson(Map<String, dynamic> json, String id) {
    return Counter(value: json[fieldValue] ?? 0, id: id);
  }

  static String fieldValue = 'value', fieldId = 'id';

  final int value;
  final String id;

  Counter copyWith({int? value, String? id}) {
    return Counter(value: value ?? this.value, id: id ?? this.id);
  }

  @override
  Map<String, dynamic> toJson() => {fieldValue: value, fieldId: id};

  @override
  String toString() => 'Counter(value: $value, id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Counter && other.value == value && other.id == id;
  }

  @override
  int get hashCode => value.hashCode ^ id.hashCode;
}
