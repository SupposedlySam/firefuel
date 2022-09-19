import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';

void main() {
  group('#firestore', () {
    test('should throw an exception when not initialized', () {
      expect(() => Firefuel.firestore, throwsA(isA<AssertionError>()));
    });

    test('should return a $FirebaseFirestore instance when initialized', () {
      Firefuel.initialize(FakeFirebaseFirestore());

      expect(Firefuel.firestore, isA<FirebaseFirestore>());
    });
  });

  group('when firestore is initialized', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    group('#env', () {
      test('should return an empty string when not initialized', () {
        expect(Firefuel.env, isEmpty);
      });

      test('should return an empty string when not provided', () {
        Firefuel.initialize(firestore);

        expect(Firefuel.env, isEmpty);
      });

      test('should return string starting with prefix when provided', () {
        const env = 'test';

        Firefuel.initialize(firestore, env: env);

        expect(Firefuel.env, startsWith(env));
      });

      test('should return prefix with "-" when provided', () {
        const env = 'test';

        Firefuel.initialize(firestore, env: env);

        expect(Firefuel.env, '$env-');
      });
    });

    group('#isOnline', () {
      test('should default to true', () {
        Firefuel.initialize(firestore);

        expect(Firefuel.isOnline, isTrue);
      });

      test('should accept initial value', () {
        Firefuel.initialize(firestore, isOnline: false);

        expect(Firefuel.isOnline, isFalse);

        Firefuel.initialize(firestore, isOnline: true);

        expect(Firefuel.isOnline, isTrue);
      });

      test('should allow changes through static setter', () {
        Firefuel.initialize(firestore);

        Firefuel.isOnline = false;

        expect(Firefuel.isOnline, isFalse);

        Firefuel.isOnline = true;

        expect(Firefuel.isOnline, isTrue);
      });
    });
  });
}
