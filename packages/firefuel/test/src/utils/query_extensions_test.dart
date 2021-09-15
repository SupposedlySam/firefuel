import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/test_user.dart';
import '../firefuel_collection_test.dart';

void main() {
  late CollectionReference<TestUser?> ref;

  setUp(() {
    Firefuel.initialize(FakeFirebaseFirestore());
    ref = TestCollection().ref;
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
}
