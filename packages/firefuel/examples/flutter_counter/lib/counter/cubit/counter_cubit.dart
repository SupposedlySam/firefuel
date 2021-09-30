import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:firefuel/firefuel.dart';

import 'package:flutter_counter/counter/data/domain/counter_model.dart';
import 'package:flutter_counter/counter/data/repo/counter_repository.dart';

/// {@template flutter_counter.counter_cubit}
/// A [Cubit] which manages a [Counter] as its state.
/// {@endtemplate}
class CounterCubit extends Cubit<Counter> {
  /// {@macro flutter_counter.counter_cubit}
  CounterCubit({
    required this.counterRepo,
  }) : super(const Counter(id: 'count', value: 0));

  final CounterRepository counterRepo;

  /// Add 1 to the current state.
  Future<void> increment() async {
    final incrementedState = state.copyWith(value: state.value + 1);

    final result = await counterRepo.updateOrCreate(
      docId: DocumentId(incrementedState.id), // docId == count
      value: incrementedState,
    );

    result.fold(
      (failure) => debugPrint(failure.error.toString()),
      (success) => emit(success),
    );
  }

  /// Subtract 1 from the current state.
  Future<void> decrement() async {
    final decrementedState = state.copyWith(value: state.value - 1);

    final result = await counterRepo.updateOrCreate(
      docId: DocumentId(decrementedState.id), // docId == count
      value: decrementedState,
    );

    result.fold(
      (failure) => debugPrint(failure.error.toString()),
      (success) => emit(success),
    );
  }
}
