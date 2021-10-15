import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../../utils/test_collection.dart';
import '../../utils/test_user.dart';

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

  group('#filter', () {
    test('should return the original query when empty', () {
      final result = ref.filter([]);

      expect(identityHashCode(result), identityHashCode(ref));
    });

    test('should return a new query', () {
      final result = ref.filter(
        [Clause(TestUser.fieldName, isEqualTo: 'testUser')],
      );

      expect(identityHashCode(result), isNot(identityHashCode(ref)));
    });
  });

  group('#startAfterIfNotNull', () {
    test('should return the original query when null', () {
      final result = ref.startAfterIfNotNull(null);

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

  group('#sortIfNotNull', () {
    test('should return the original query when null', () {
      final result = ref.sortIfNotNull(null);

      expect(identityHashCode(result), identityHashCode(ref));
    });

    test('should return the original query when empty', () {
      final result = ref.sortIfNotNull([]);

      expect(identityHashCode(result), identityHashCode(ref));
    });

    test('should return a new query when not null', () async {
      final result = ref.sortIfNotNull([OrderBy(field: TestUser.fieldName)]);

      expect(identityHashCode(result), isNot(identityHashCode(ref)));
    });
  });

  group('#sort', () {
    test('should return the original query when empty', () {
      final result = ref.filterIfNotNull([]);

      expect(identityHashCode(result), identityHashCode(ref));
    });

    test('should return a new query', () {
      final result = ref.sort([OrderBy(field: TestUser.fieldName)]);

      expect(identityHashCode(result), isNot(identityHashCode(ref)));
    });
  });

  group('#limitIfNotNull', () {
    test('should return the original query when null', () {
      final result = ref.limitIfNotNull(null);

      expect(identityHashCode(result), identityHashCode(ref));
    });

    test('should return a new query when not null', () {
      final result = ref.limitIfNotNull(10);

      expect(identityHashCode(result), isNot(identityHashCode(ref)));
    });
  });
}
