import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
