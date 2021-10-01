import 'package:flutter/material.dart';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel_counter/firefuel_counter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../counter.dart';
import 'counter_view.dart';

/// {@template counter_page}
/// A [StatelessWidget] which is responsible for providing a
/// [CounterCubit] instance to the [CounterView].
/// {@endtemplate}
class CounterPage extends StatelessWidget {
  /// {@macro counter_page}
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counterRepo = CounterRepository(collection: CounterCollection());
    final getInitialCounter = counterRepo.readOrCreate(
      docId: DocumentId('counter'),
      createValue: Counter.initial(),
    );

    return FutureBuilder<Either<Failure, Counter>>(
        future: getInitialCounter,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!.fold(
              (failure) {
                return Scaffold(
                  body: Center(
                    child: SelectableText(
                      failure.error.toString(),
                    ),
                  ),
                );
              },
              (counter) {
                return BlocProvider(
                  create: (_) => CounterCubit(
                    counterRepo: counterRepo,
                    defaultValue: counter,
                  ),
                  child: CounterView(),
                );
              },
            );
          }

          return Scaffold(body: Center(child: Text('Please Wait...')));
        });
  }
}
