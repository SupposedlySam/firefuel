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
    // Create a repository(optional) from the counter collection. The counter
    // collection contains the logic to reach out to the database, the
    // repository is just responsible for hanling failures.
    final counterRepo = CounterRepository(collection: CounterCollection());

    // Get the counter from the database using the counter repository (which
    // calls the CounterCollection)
    final getInitialCounter = counterRepo.readOrCreate(
      docId: DocumentId('counter'),
      createValue: Counter.initial(),
    );

    return FutureBuilder<Either<Failure, Counter>>(
        future: getInitialCounter,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Since the repository returned an `Either` class, we can safely
            // access "either" the failure or the success value with the `fold`
            // method.
            //
            // Only one of the below widgets will show at a time. Either the
            // failure or the success widget will be shown based on the result
            // of the call to `readOrCreate`
            return snapshot.data!.fold(
              // The first positional argument to `fold` is to handle the
              // failure case if the call to `readOrCreate` throws an error.
              (failure) {
                return Scaffold(
                  body: Center(
                    child: SelectableText(
                      failure.error.toString(),
                    ),
                  ),
                );
              },
              // The second positional argument to `fold` is to handle the
              // success case if the call to `readOrCreate` does not throw an
              // error.
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
