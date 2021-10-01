import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:firefuel_counter/firefuel_counter.dart';
import 'package:firefuel/firefuel.dart';

/// {@template flutter_counter.counter_cubit}
/// A [Cubit] which manages a [Counter] as its state.
/// {@endtemplate}
class CounterCubit extends Cubit<Counter> {
  /// {@macro flutter_counter.counter_cubit}
  CounterCubit({
    required this.counterRepo,
    required this.defaultValue,
  }) : super(defaultValue);

  static const _stepper = Counter(1);
  final CounterRepository counterRepo;
  final Counter defaultValue;

  /// Add 1 to the current state.
  Future<void> increment() async {
    final result = await counterRepo.increment(
      docId: DocumentId(state.id),
      counter: _stepper,
    );

    result.fold(
      (failure) => debugPrint(failure.error.toString()),
      (success) => emit(success),
    );
  }

  /// Subtract 1 from the current state.
  Future<void> decrement() async {
    final result = await counterRepo.decrement(
      docId: DocumentId(state.id),
      counter: _stepper,
    );

    result.fold(
      (failure) => debugPrint(failure.error.toString()),
      (success) => emit(success),
    );
  }
}
