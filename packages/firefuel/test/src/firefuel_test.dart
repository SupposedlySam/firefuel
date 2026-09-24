import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../utils/test_backend.dart';

void main() {
  group('#firestore', () {
    setUp(Firefuel.reset);

    tearDown(Firefuel.reset);

    test('should throw a StateError when not initialized', () {
      expect(() => Firefuel.firestore, throwsStateError);
    });

    test(
      'should return a $FirebaseFirestore instance when initialized',
      () async {
        Firefuel.initialize(await testFirestore());

        expect(Firefuel.firestore, isA<FirebaseFirestore>());
      },
    );
  });

  group('#env', () {
    late FirebaseFirestore firestore;

    setUp(() async {
      firestore = await testFirestore();
    });

    test('should return an empty string when not initialized', () {
      expect(Firefuel.env, isEmpty);
    });

    test('should return an empty string when not provided', () {
      Firefuel.initialize(firestore);

      expect(Firefuel.env, isEmpty);

      Firefuel.reset();
    });

    test('should return string starting with prefix when provided', () {
      const env = 'test';

      Firefuel.initialize(firestore, env: env);

      expect(Firefuel.env, startsWith(env));

      Firefuel.reset();
    });

    test('should return prefix with "-" when provided', () {
      const env = 'test';

      Firefuel.initialize(firestore, env: env);

      expect(Firefuel.env, '$env-');

      Firefuel.reset();
    });
  });
}
