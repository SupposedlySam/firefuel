import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_counter/counter/counter.dart';
import 'package:firefuel_counter/firefuel_counter.dart';

void main() {
  final docId = DocumentId('count');
  late CounterCubit counterCubit;
  late CounterRepository counterRepo;

  setUp(() async {
    Firefuel.initialize(FakeFirebaseFirestore());

    counterRepo = CounterRepository(
      collection: CounterCollection(),
    );

    final defaultValue = await counterRepo.readOrCreate(
      docId: docId,
      createValue: Counter.initial(),
    );

    counterCubit = CounterCubit(
      counterRepo: counterRepo,
      defaultValue: defaultValue.getRight(),
    );
  });

  group('CounterCubit', () {
    test('initial state is 0', () {
      expect(counterCubit.state, const Counter(0));
    });

    group('increment', () {
      blocTest<CounterCubit, Counter>(
        'emits [1] when state is 0',
        build: () => counterCubit,
        act: (cubit) async => await cubit.increment(),
        expect: () => const <Counter>[Counter(1)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [1, 2] when state is 0 and invoked twice',
        build: () => counterCubit,
        act: (cubit) async {
          await cubit.increment();
          await cubit.increment();
        },
        expect: () => const <Counter>[Counter(1), Counter(2)],
      );

      group('with default of 41', () {
        setUp(() async {
          await counterRepo.update(
            docId: docId,
            value: Counter(41),
          );

          counterCubit = CounterCubit(
            counterRepo: counterRepo,
            defaultValue: Counter(41),
          );
        });

        blocTest<CounterCubit, Counter>(
          'emits [42] when state is 41',
          build: () => counterCubit,
          act: (cubit) async => await cubit.increment(),
          expect: () => const <Counter>[Counter(42)],
        );
      });
    });

    group('decrement', () {
      blocTest<CounterCubit, Counter>(
        'emits [-1] when state is 0',
        build: () => counterCubit,
        act: (cubit) async => await cubit.decrement(),
        expect: () => const <Counter>[Counter(-1)],
      );

      blocTest<CounterCubit, Counter>(
        'emits [-1, -2] when state is 0 and invoked twice',
        build: () => counterCubit,
        act: (cubit) async {
          await cubit.decrement();
          await cubit.decrement();
        },
        expect: () => const <Counter>[Counter(-1), Counter(-2)],
      );

      group('with default of 43', () {
        setUp(() async {
          await counterRepo.update(
            docId: docId,
            value: Counter(43),
          );

          counterCubit = CounterCubit(
            counterRepo: counterRepo,
            defaultValue: Counter(43),
          );
        });

        blocTest<CounterCubit, Counter>(
          'emits [42] when state is 43',
          build: () => counterCubit,
          act: (cubit) async => await cubit.decrement(),
          expect: () => const <Counter>[Counter(42)],
        );
      });
    });
  });
}
