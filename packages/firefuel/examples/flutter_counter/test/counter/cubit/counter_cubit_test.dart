import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_counter/counter/counter.dart';
import 'package:flutter_counter/counter/data/collection/counter_collection.dart';
import 'package:flutter_counter/counter/data/domain/counter_model.dart';
import 'package:flutter_counter/counter/data/repo/counter_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(() {
    Firefuel.initialize(FakeFirebaseFirestore());
  });

  group('CounterCubit', () {
    test('initial state is 0', () {
      expect(
        CounterCubit(counterRepo: TestCounterRepository()).state,
        const TestCounter(0),
      );
    });

    group('increment', () {
      blocTest<CounterCubit, Counter>(
        'emits [1] when state is 0',
        build: () => CounterCubit(counterRepo: TestCounterRepository()),
        act: (cubit) => cubit.increment(),
        wait: const Duration(milliseconds: 300),
        expect: () => const <Counter>[TestCounter(1)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [1, 2] when state is 0 and invoked twice',
        build: () => CounterCubit(counterRepo: TestCounterRepository()),
        act: (cubit) => cubit
          ..increment()
          ..increment(),
        expect: () => const <Counter>[TestCounter(1), TestCounter(2)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [42] when state is 41',
        build: () => CounterCubit(counterRepo: TestCounterRepository()),
        seed: () => const TestCounter(41),
        act: (cubit) => cubit.increment(),
        expect: () => const <Counter>[TestCounter(42)],
      );
    });

    group('decrement', () {
      blocTest<CounterCubit, Counter>(
        'emits [-1] when state is 0',
        build: () => CounterCubit(counterRepo: TestCounterRepository()),
        act: (cubit) async => await cubit.decrement(),
        expect: () => const <Counter>[TestCounter(-1)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [-1, -2] when state is 0 and invoked twice',
        build: () => CounterCubit(counterRepo: TestCounterRepository()),
        act: (cubit) => cubit
          ..decrement()
          ..decrement(),
        expect: () => const <Counter>[TestCounter(-1), TestCounter(-2)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [42] when state is 43',
        build: () => CounterCubit(counterRepo: TestCounterRepository()),
        seed: () => const Counter(id: 'count', value: 43),
        act: (cubit) => cubit.decrement(),
        expect: () => const <Counter>[TestCounter(42)],
      );
    });
  });
}

class TestCounter extends Counter {
  const TestCounter(int value) : super(id: 'count', value: value);
}

class TestCounterRepository extends CounterRepository {
  TestCounterRepository() : super(collection: TestCollection());
}

class TestCollection extends Mock implements CounterCollection {}
