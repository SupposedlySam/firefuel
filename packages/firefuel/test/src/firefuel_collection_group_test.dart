import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../utils/test_user.dart';

/// Reactions live under many message pods; the group reads them all.
class ReactionGroup extends FirefuelCollectionGroup<TestUser> {
  ReactionGroup({super.firestore}) : super('reactions');

  @override
  TestUser? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return data == null ? null : TestUser.fromJson(data, snapshot.id);
  }
}

class ReactionGroupRepository extends FirefuelQueryRepository<TestUser> {
  ReactionGroupRepository(ReactionGroup group) : super(source: group);
}

void main() {
  late FakeFirebaseFirestore firestore;
  late ReactionGroup group;

  Future<void> react(String pod, String user, {required int age}) {
    return firestore
        .collection('conversations/c1/messagePods/$pod/reactions')
        .doc(user)
        .set(TestUser(user, age: age, occupation: pod).toJson());
  }

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    Firefuel.initialize(firestore);
    group = ReactionGroup();

    await react('p1', 'fry', age: 25);
    await react('p1', 'leela', age: 27);
    await react('p2', 'bender', age: 4);
    // Same subcollection name at a different depth is still in the group.
    await firestore
        .collection('users/u1/reactions')
        .doc('zoidberg')
        .set(const TestUser('zoidberg', age: 80).toJson());
    // A differently named subcollection is not.
    await firestore
        .collection('conversations/c1/messagePods/p1/other')
        .doc('nibbler')
        .set(const TestUser('nibbler', age: 1).toJson());
  });

  tearDown(Firefuel.reset);

  test(
    'readAll should read every member of the group and nothing else',
    () async {
      final names = (await group.readAll()).map((user) => user.name).toSet();

      expect(names, {'fry', 'leela', 'bender', 'zoidberg'});
    },
  );

  test('where should filter across parents', () async {
    final users = await group.where(
      [Clause(TestUser.fieldAge, isLessThan: 26)],
      orderBy: [OrderBy(field: TestUser.fieldAge)],
    );

    expect(users.map((user) => user.name), ['bender', 'fry']);
  });

  test('countWhere should count across parents', () async {
    expect(
      await group.countWhere([
        Clause(TestUser.fieldOccupation, isEqualTo: 'p1'),
      ]),
      2,
    );
  });

  test('snapshots should say which parent each result came from', () async {
    final snapshot = await group
        .snapshots(
          FirefuelQuery(
            clauses: [Clause(TestUser.fieldAge, isLessThan: 50)],
            orderBy: [OrderBy(field: TestUser.fieldAge)],
          ),
        )
        .first;

    expect(
      snapshot.docs.map((doc) => (doc.id, doc.ancestorId('messagePods'))),
      [('bender', 'p2'), ('fry', 'p1'), ('leela', 'p1')],
    );
  });

  test('paginate should page across parents', () async {
    final seen = <String>[];
    var chunk = Chunk<TestUser>(
      orderBy: [OrderBy(field: TestUser.fieldAge)],
      limit: 3,
    );

    do {
      chunk = await group.paginate(chunk);
      seen.addAll(chunk.data.map((user) => user.name));
    } while (chunk.status == ChunkStatus.nextAvailable);

    expect(seen, ['bender', 'fry', 'leela', 'zoidberg']);
  });

  test('a repository should wrap group reads in Either', () async {
    final repository = ReactionGroupRepository(group);

    final result = await repository.countAll();

    expect(result.getRightOrElseNull(), 4);
  });

  test('should read a pinned instance', () async {
    final other = FakeFirebaseFirestore();
    await other
        .collection('a/1/reactions')
        .doc('amy')
        .set(const TestUser('amy').toJson());

    final users = await ReactionGroup(firestore: other).readAll();

    expect(users.map((user) => user.name), ['amy']);
  });

  test('should follow Firefuel.initialize after construction', () async {
    final second = FakeFirebaseFirestore();
    await second
        .collection('x/1/reactions')
        .doc('hermes')
        .set(const TestUser('hermes').toJson());

    await group.readAll();
    Firefuel.initialize(second);

    expect((await group.readAll()).map((user) => user.name), ['hermes']);
  });

  test(
    'should ignore Firefuel.env, which prefixes top-level names only',
    () async {
      Firefuel.initialize(firestore, env: 'dev');

      expect(await ReactionGroup().countAll(), 4);
    },
  );

  test('should expose no writes', () {
    // A group has no single parent to write into; the type system is the
    // guard, so no write method exists to call.
    expect(group, isNot(isA<Collection<TestUser>>()));
  });
}
