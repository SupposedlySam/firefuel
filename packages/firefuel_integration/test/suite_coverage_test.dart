import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The real-Firestore suite must run every firefuel test file that can run
/// against a real backend. A file added to firefuel without an entry in
/// integration_test/firefuel_suite_test.dart would otherwise only ever run
/// against the fake, and nothing would say so.
void main() {
  test('every backend-aware firefuel test file is in the suite', () {
    final suite = File(
      'integration_test/firefuel_suite_test.dart',
    ).readAsStringSync();
    final testDir = Directory('../firefuel/test/src');

    final backendAware = testDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_test.dart'))
        .where((file) => file.readAsStringSync().contains('test_backend.dart'))
        .map((file) => file.path.substring(testDir.path.length + 1))
        .toList();

    // Population: the suite is only meaningful if files were found.
    expect(backendAware, isNotEmpty);
    for (final path in backendAware) {
      expect(
        suite,
        contains("firefuel/test/src/$path'"),
        reason: '$path uses testFirestore() but is not in the suite',
      );
    }
  });
}
