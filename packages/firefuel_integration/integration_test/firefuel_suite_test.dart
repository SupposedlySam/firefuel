// Runs firefuel's own test files against a real Firestore: the emulator
// (tool/test_real_firestore.sh) or the live firefuel-integration project
// (tool/test_live_firestore.sh).
//
//   firebase emulators:exec --config ../../firebase.emulator.json \
//     --only firestore --project demo-firefuel \
//     "flutter test integration_test/firefuel_suite_test.dart -d macos"
//
// Every firefuel test file that gets Firestore from testFirestore() belongs
// here; test/suite_coverage_test.dart fails when one is missing.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../firefuel/test/src/firefuel_batch_test.dart' as firefuel_batch;
import '../../firefuel/test/src/firefuel_collection_group_test.dart'
    as firefuel_collection_group;
import '../../firefuel/test/src/firefuel_collection_test.dart'
    as firefuel_collection;
import '../../firefuel/test/src/firefuel_observer_test.dart'
    as firefuel_observer;
import '../../firefuel/test/src/firefuel_test.dart' as firefuel;
import '../../firefuel/test/src/query/firefuel_query_test.dart'
    as query_firefuel_query;
import '../../firefuel/test/src/query/query_power_test.dart'
    as query_query_power;
import '../../firefuel/test/src/review_regressions_test.dart'
    as review_regressions;
import '../../firefuel/test/src/snapshots_test.dart' as snapshots;
import '../../firefuel/test/src/write_scopes_test.dart' as write_scopes;
import '../../firefuel/test/src/write_values_test.dart' as write_values;
import '../../firefuel/test/utils/test_backend.dart';
import 'support/emulator_backend.dart';
import 'support/live_backend.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Installed before any test is declared: skip reasons read it.
  installTestBackend(
    const String.fromEnvironment('FIREFUEL_BACKEND') == 'live'
        ? LiveBackend()
        : EmulatorBackend(),
  );

  group('firefuel_batch_test.dart', firefuel_batch.main);
  group('firefuel_collection_group_test.dart', firefuel_collection_group.main);
  group('firefuel_collection_test.dart', firefuel_collection.main);
  group('firefuel_observer_test.dart', firefuel_observer.main);
  group('firefuel_test.dart', firefuel.main);
  group('query/firefuel_query_test.dart', query_firefuel_query.main);
  group('query/query_power_test.dart', query_query_power.main);
  group('review_regressions_test.dart', review_regressions.main);
  group('snapshots_test.dart', snapshots.main);
  group('write_scopes_test.dart', write_scopes.main);
  group('write_values_test.dart', write_values.main);
}
