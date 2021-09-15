import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/test_user.dart';
import '../firefuel_collection_test.dart';

void main() {
  late TestCollection testCollection;
  late CollectionReference<TestUser?> ref;

  setUp(() {
    Firefuel.initialize(FakeFirebaseFirestore());
    testCollection = TestCollection();
    ref = testCollection.ref;
  });

  group('#filterIfNotNull', () {
    test('should return the original query when null', () {
      final result = ref.filterIfNotNull(null);

      expect(identityHashCode(result), identityHashCode(ref));
    });

    test('should return the original query when empty', () {
      final result = ref.filterIfNotNull([]);

      expect(identityHashCode(result), identityHashCode(ref));
    });

    test('should return a new query when not null', () {
      final result = ref.filterIfNotNull(
        [Clause(TestUser.fieldName, isEqualTo: 'testUser')],
      );

      expect(identityHashCode(result), isNot(identityHashCode(ref)));
    });
  });

  group('#startAfterIfNotNull', () {
    test('should return the original query when null', () {
      final result = ref.filterIfNotNull(null);

      expect(identityHashCode(result), identityHashCode(ref));
    });

    test('should return a new query when not null', () async {
      final defaultUser = TestUser('testUser');
      final docId = await testCollection.create(defaultUser);
      final documentSnapshot = await testCollection.ref.doc(docId.docId).get();
      final result = ref.startAfterIfNotNull(documentSnapshot);

      expect(identityHashCode(result), isNot(identityHashCode(ref)));
    });
  });

  group('#orderIfNotNull', () {
    test('should return the original query when null', () {
      final result = ref.filterIfNotNull(null);

      expect(identityHashCode(result), identityHashCode(ref));
    });

    test('should return a new query when not null', () async {
      final result = ref.orderIfNotNull(TestUser.fieldName);

      expect(identityHashCode(result), isNot(identityHashCode(ref)));
    });
  });
}
