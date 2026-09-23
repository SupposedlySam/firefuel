import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../../utils/test_collection.dart';
import '../../utils/test_user.dart';

void main() {
  late TestCollection collection;

  setUp(() async {
    Firefuel.initialize(FakeFirebaseFirestore());
    collection = TestCollection();

    for (var age = 1; age <= 6; age++) {
      await collection.create(
        TestUser('user$age', age: age, occupation: age.isEven ? 'even' : 'odd'),
      );
    }
  });

  tearDown(Firefuel.reset);

  Future<List<int?>> agesOf(FirefuelQuery query) async {
    final users = await collection.query(query);

    return users.map((user) => user.age).toList();
  }

  final byAge = [OrderBy(field: TestUser.fieldAge)];

  group('$FirefuelQuery', () {
    group('validation', () {
      test('should refuse limit and limitToLast together', () {
        expect(
          () => FirefuelQuery(orderBy: byAge, limit: 1, limitToLast: 1),
          throwsArgumentError,
        );
      });

      test('should require an orderBy for limitToLast', () {
        expect(
          () => FirefuelQuery(limitToLast: 1),
          throwsA(isA<MissingValueException>()),
        );
      });

      test('should require an orderBy for cursors', () {
        expect(
          () => FirefuelQuery(start: const StartCursor.at([1])),
          throwsA(isA<MissingValueException>()),
        );
        expect(
          () => FirefuelQuery(end: const EndCursor.before([1])),
          throwsA(isA<MissingValueException>()),
        );
      });
    });

    test('an empty query should read everything', () async {
      expect(await agesOf(FirefuelQuery()), hasLength(6));
    });

    test('should apply clauses, order and limit together', () async {
      expect(
        await agesOf(
          FirefuelQuery(
            clauses: [Clause(TestUser.fieldOccupation, isEqualTo: 'even')],
            orderBy: [
              OrderBy(field: TestUser.fieldAge, direction: OrderDirection.desc),
            ],
            limit: 2,
          ),
        ),
        [6, 4],
      );
    });

    test('limitToLast should keep the end of the order', () async {
      expect(await agesOf(FirefuelQuery(orderBy: byAge, limitToLast: 2)), [
        5,
        6,
      ]);
    });

    group('cursors', () {
      test('StartCursor.at should include the value', () async {
        expect(
          await agesOf(
            FirefuelQuery(orderBy: byAge, start: const StartCursor.at([4])),
          ),
          [4, 5, 6],
        );
      });

      test('StartCursor.after should exclude the value', () async {
        expect(
          await agesOf(
            FirefuelQuery(orderBy: byAge, start: const StartCursor.after([4])),
          ),
          [5, 6],
        );
      });

      test('EndCursor.at should include the value', () async {
        expect(
          await agesOf(
            FirefuelQuery(orderBy: byAge, end: const EndCursor.at([2])),
          ),
          [1, 2],
        );
      });

      test('EndCursor.before should exclude the value', () async {
        expect(
          await agesOf(
            FirefuelQuery(orderBy: byAge, end: const EndCursor.before([2])),
          ),
          [1],
        );
      });

      test('should combine a start, an end and a limit', () async {
        expect(
          await agesOf(
            FirefuelQuery(
              orderBy: byAge,
              start: const StartCursor.after([1]),
              end: const EndCursor.at([5]),
              limit: 3,
            ),
          ),
          [2, 3, 4],
        );
      });
    });

    test('streamQuery should emit the same documents as query', () async {
      final query = FirefuelQuery(orderBy: byAge, limitToLast: 3);

      final streamed = await collection.streamQuery(query).first;

      expect(streamed.map((user) => user.age), [4, 5, 6]);
    });

    test('copyWith should replace only the given parts', () {
      final original = FirefuelQuery(orderBy: byAge, limit: 2);

      final copy = original.copyWith(limit: 5);

      expect(copy.limit, 5);
      expect(copy.orderBy, byAge);
      expect(copy, isNot(original));
      expect(original.copyWith(), original);
    });

    group('effectiveOrderBy', () {
      test('should leave the order alone without clauses', () {
        final orderBy = [OrderBy(field: TestUser.fieldName)];

        expect(FirefuelQuery(orderBy: orderBy).effectiveOrderBy, orderBy);
      });

      test('should lead with the range field', () {
        final query = FirefuelQuery(
          clauses: [Clause(TestUser.fieldAge, isGreaterThan: 2)],
          orderBy: [OrderBy(field: TestUser.fieldName)],
        );

        expect(query.effectiveOrderBy.map((o) => o.field), [
          TestUser.fieldAge,
          TestUser.fieldName,
        ]);
      });
    });
  });

  group('$Chunk.query', () {
    test('should page through a query that has clauses and order', () async {
      final seen = <int?>[];
      var chunk = Chunk<TestUser>.query(
        FirefuelQuery(
          clauses: [Clause(TestUser.fieldOccupation, isEqualTo: 'odd')],
          orderBy: byAge,
          limit: 2,
        ),
      );

      do {
        chunk = await collection.paginate(chunk);
        seen.addAll(chunk.data.map((user) => user.age));
      } while (chunk.status == ChunkStatus.nextAvailable);

      expect(seen, [1, 3, 5]);
    });

    test('should default the page size', () {
      final chunk = Chunk<TestUser>.query(FirefuelQuery(orderBy: byAge));

      expect(chunk.limit, Chunk.defaultLimit);
    });

    test('should refuse queries that do not walk forward', () {
      expect(
        () => Chunk<TestUser>.query(
          FirefuelQuery(orderBy: byAge, limitToLast: 2),
        ),
        throwsArgumentError,
      );
    });
  });
}
