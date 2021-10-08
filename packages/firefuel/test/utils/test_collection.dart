import 'package:firefuel/firefuel.dart';

import 'test_user.dart';

class TestCollection extends FirefuelCollection<TestUser> {
  TestCollection() : super(testUsersCollectionName);

  static const testUsersCollectionName = 'testUsers';

  @override
  TestUser? fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return data == null
        ? null
        : TestUser.fromJson(snapshot.data()!, snapshot.id);
  }

  @override
  Map<String, Object?> toFirestore(TestUser? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
