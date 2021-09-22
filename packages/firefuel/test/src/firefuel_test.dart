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

  group('#collectionPrefix', () {
    test('should return an empty string when not initialized', () {
      expect(Firefuel.collectionPrefix, isEmpty);
    });

    test('should return an empty string when not provided', () {
      Firefuel.initialize(FakeFirebaseFirestore());

      expect(Firefuel.collectionPrefix, isEmpty);
    });

    test('should return string starting with prefix when provided', () {
      const collectionPrefix = 'test';

      Firefuel.initialize(
        FakeFirebaseFirestore(),
        collectionPrefix: collectionPrefix,
      );

      expect(Firefuel.collectionPrefix.startsWith(collectionPrefix), isTrue);
    });

    test('should return prefix with "-" when provided', () {
      const collectionPrefix = 'test';

      Firefuel.initialize(
        FakeFirebaseFirestore(),
        collectionPrefix: collectionPrefix,
      );

      expect(Firefuel.collectionPrefix, equals('$collectionPrefix-'));
    });
  });
}
