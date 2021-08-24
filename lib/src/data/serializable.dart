import 'package:equatable/equatable.dart';

abstract class Serializable extends Equatable {
  const Serializable();

  Map<String, dynamic> toJson();
}
