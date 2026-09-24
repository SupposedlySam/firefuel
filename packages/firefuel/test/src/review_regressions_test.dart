import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../utils/test_collection.dart';
import '../utils/test_user.dart';
import '../utils/test_backend.dart';

/// Defects found by the independent correctness review of 0.5 (2026-09-23).
void main() {
  late TestCollection users;

  setUp(() async {
    Firefuel.initialize(await testFirestore());
    users = TestCollection();
  });

  tearDown(Firefuel.reset);

  group('cursors against a rewritten order', () {
    // With a range clause Firestore needs the range field first, so
    // effectiveOrderBy inserts it. Cursor values line up with the order the
    // caller wrote, so they would silently compare against the wrong field.
    test('should refuse cursors when the order would be rewritten', () {
      expect(
        () => FirefuelQuery(
          clauses: [Clause(TestUser.fieldAge, isGreaterThan: 18)],
          orderBy: [OrderBy(field: TestUser.fieldName)],
          start: const StartCursor.after(['Bob']),
        ),
        throwsArgumentError,
      );
    });

    test('should refuse limitToLast when the rewrite empties the order', () {
      expect(
        () => FirefuelQuery(
          clauses: [Clause(TestUser.fieldOccupation, isEqualTo: 'x')],
          orderBy: [OrderBy(field: TestUser.fieldOccupation)],
          limitToLast: 5,
        ),
        throwsArgumentError,
      );
    });

    test(
      'should accept cursors when the order already satisfies Firestore',
      () {
        expect(
          () => FirefuelQuery(
            clauses: [Clause(TestUser.fieldAge, isGreaterThan: 18)],
            orderBy: [
              OrderBy(field: TestUser.fieldAge),
              OrderBy(field: TestUser.fieldName),
            ],
            start: const StartCursor.after([20, 'Bob']),
          ),
          returnsNormally,
        );
      },
    );
  });

  test(
    'isNull: false should keep its sort (it is != null, not equality)',
    () async {
      await users.create(const TestUser('a', age: 1));
      await users.create(const TestUser('b', age: 3));
      await users.create(const TestUser('c', age: 2));

      final sorted = await users.where(
        [Clause(TestUser.fieldAge, isNull: false)],
        orderBy: [
          OrderBy(field: TestUser.fieldAge, direction: OrderDirection.desc),
        ],
      );

      expect(sorted.map((user) => user.age), [3, 2, 1]);
    },
  );

  group('equality', () {
    test('clauses with different operators should differ', () {
      expect(
        Clause('age', isLessThan: 18),
        isNot(Clause('age', isGreaterThan: 18)),
      );
      expect(Clause('age', isLessThan: 18), Clause('age', isLessThan: 18));
    });

    test('an OR group should differ from an AND group', () {
      final clause = Clause('age', isEqualTo: 1);
      expect(Clause.or([clause]), isNot(Clause.and([clause])));
    });

    test('orderBy should compare byId and the effective direction', () {
      expect(const OrderBy.docId(), isNot(OrderBy(field: 'unused')));
      expect(
        const OrderBy.docId(OrderDirection.zToA),
        const OrderBy.docId(OrderDirection.desc),
      );
    });
  });

  test('an empty last page should keep its cursor', () async {
    for (var i = 0; i < 4; i++) {
      await users.create(TestUser('user$i', age: i));
    }
    var chunk = Chunk<TestUser>(
      orderBy: [OrderBy(field: TestUser.fieldAge)],
      limit: 2,
    );

    chunk = await users.paginate(chunk); // 0, 1
    chunk = await users.paginate(chunk); // 2, 3 (a full page)
    chunk = await users.paginate(chunk); // empty, last

    expect(chunk.status, ChunkStatus.last);
    expect(chunk.data, isEmpty);

    // Paginating again must not restart at page one.
    final again = await users.paginate(chunk);
    expect(again.data, isEmpty);
  });

  test('groups and aggregates should reject more than Firestore allows', () {
    final many = List.generate(31, (i) => Clause('f$i', isEqualTo: i));
    expect(() => Clause.or(many), throwsArgumentError);
    expect(
      () => users.aggregate(
        FirefuelQuery(),
        sums: List.generate(31, (i) => 'f$i'),
      ),
      throwsArgumentError,
    );
  });
}
