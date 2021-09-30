// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:flutter_counter/counter/counter.dart';
import 'package:flutter_counter/counter/data/collection/counter_collection.dart';
import 'package:flutter_counter/counter/data/domain/counter_model.dart';
import 'package:flutter_counter/counter/data/repo/counter_repository.dart';
import '../../utils/test_counter.dart';

void main() {
  late CounterCubit counterCubit;

  setUp(() {
    Firefuel.initialize(FakeFirebaseFirestore());
    final counterRepository =
        CounterRepository(collection: CounterCollection());
    counterCubit = CounterCubit(counterRepo: counterRepository);
  });

  group('CounterCubit', () {
    test('initial state is 0', () {
      expect(counterCubit.state, const TestCounter(0));
    });

    group('increment', () {
      blocTest<CounterCubit, Counter>(
        'emits [1] when state is 0',
        build: () => counterCubit,
        act: (cubit) async => await cubit.increment(),
        expect: () => const <Counter>[TestCounter(1)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [1, 2] when state is 0 and invoked twice',
        build: () => counterCubit,
        act: (cubit) async {
          await cubit.increment();
          await cubit.increment();
        },
        expect: () => const <Counter>[TestCounter(1), TestCounter(2)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [42] when state is 41',
        build: () => counterCubit,
        seed: () => const TestCounter(41),
        act: (cubit) async => await cubit.increment(),
        expect: () => const <Counter>[TestCounter(42)],
      );
    });

    group('decrement', () {
      blocTest<CounterCubit, Counter>(
        'emits [-1] when state is 0',
        build: () => counterCubit,
        act: (cubit) async => await cubit.decrement(),
        expect: () => const <Counter>[TestCounter(-1)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [-1, -2] when state is 0 and invoked twice',
        build: () => counterCubit,
        act: (cubit) async {
          await cubit.decrement();
          await cubit.decrement();
        },
        expect: () => const <Counter>[TestCounter(-1), TestCounter(-2)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [42] when state is 43',
        build: () => counterCubit,
        seed: () => const Counter(id: 'count', value: 43),
        act: (cubit) async => await cubit.decrement(),
        expect: () => const <Counter>[TestCounter(42)],
      );
    });
  });
}
