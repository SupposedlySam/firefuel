import 'package:firefuel/firefuel.dart';

class Counter extends Serializable {
  const Counter({
    required this.value,
    required this.id,
  });

  factory Counter.fromJson(Map<String, dynamic> map) {
    return Counter(
      value: map['value'] ?? 0,
      id: map['id'] ?? '',
    );
  }

  final int value;
  final String id;

  Counter copyWith({
    int? value,
    String? id,
  }) {
    return Counter(
      value: value ?? this.value,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'id': id,
    };
  }

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
