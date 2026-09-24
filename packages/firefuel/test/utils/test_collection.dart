import 'package:firefuel/firefuel.dart';

import 'test_user.dart';

class TestCollection extends FirefuelCollection<TestUser> {
  TestCollection({super.firestore}) : super(testUsersCollectionName);

  static const testUsersCollectionName = 'testUsers';

  @override
  TestUser? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    return switch (snapshot.data()) {
      final data? => TestUser.fromJson(data, snapshot.id),
      null => null,
    };
  }

  @override
  Map<String, Object?> toFirestore(TestUser? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
