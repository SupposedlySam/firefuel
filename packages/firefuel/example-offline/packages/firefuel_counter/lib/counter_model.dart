import 'package:firefuel/firefuel.dart';

class Counter extends Serializable {
  static const _defaultId = 'count';
  const Counter(this.value, {this.id = _defaultId});
  const Counter.initial()
      : value = 0,
        id = _defaultId;

  factory Counter.fromJson(Map<String, dynamic> json, String id) {
    return Counter(json[fieldValue], id: id);
  }

  static String fieldValue = 'value';

  final int value;
  final String id;

  /// Add the current value to the provided [counter]'s value
  ///
  /// returns a new instance
  Counter add(Counter counter) {
    final sum = value + counter.value;

    return copyWith(value: sum);
  }

  /// Subtract the current value by the provided [counter]'s value
  ///
  /// returns a new instance
  Counter subtract(Counter counter) {
    final diff = value - counter.value;

    return copyWith(value: diff);
  }

  Counter copyWith({int? value, String? id}) {
    return Counter(value ?? this.value, id: id ?? this.id);
  }

  @override
  Map<String, dynamic> toJson() => {fieldValue: value};

  @override
  String toString() => 'Counter($fieldValue: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Counter && other.value == value && other.id == id;
  }

  @override
  int get hashCode => value.hashCode ^ id.hashCode;
}
