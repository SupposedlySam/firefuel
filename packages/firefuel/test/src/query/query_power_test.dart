import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../../utils/test_collection.dart';
import '../../utils/test_repository.dart';
import '../../utils/test_user.dart';
import '../../utils/test_backend.dart';

void main() {
  late TestCollection users;

  setUp(() async {
    Firefuel.initialize(await testFirestore());
    users = TestCollection();

    await users.create(const TestUser('fry', age: 25, occupation: 'delivery'));
    await users.create(const TestUser('leela', age: 27, occupation: 'captain'));
    await users.create(const TestUser('bender', age: 4, occupation: 'robot'));
    await users.create(const TestUser('farnsworth', age: 160));
    // Meets only one side of the AND below, so an AND lowered as an OR
    // would wrongly include him.
    await users.create(
      const TestUser('hermes', age: 25, occupation: 'bureaucrat'),
    );
  });

  tearDown(Firefuel.reset);

  Future<Set<String>> namesWhere(List<Clause> clauses) async {
    return (await users.where(clauses)).map((user) => user.name).toSet();
  }

  group('$Clause.or', () {
    test('should match documents meeting any branch', () async {
      expect(
        await namesWhere([
          Clause.or([
            Clause(TestUser.fieldAge, isLessThan: 10),
            Clause(TestUser.fieldAge, isGreaterThan: 100),
          ]),
        ]),
        {'bender', 'farnsworth'},
      );
    });

    test('should combine with top-level clauses as AND', () async {
      expect(
        await namesWhere([
          Clause(TestUser.fieldAge, isLessThan: 100),
          Clause.or([
            Clause(TestUser.fieldOccupation, isEqualTo: 'captain'),
            Clause(TestUser.fieldOccupation, isEqualTo: 'robot'),
          ]),
        ]),
        {'leela', 'bender'},
      );
    });

    test('should nest an AND inside an OR', () async {
      expect(
        await namesWhere([
          Clause.or([
            Clause.and([
              Clause(TestUser.fieldOccupation, isEqualTo: 'delivery'),
              Clause(TestUser.fieldAge, isEqualTo: 25),
            ]),
            Clause(TestUser.fieldName, isEqualTo: 'farnsworth'),
          ]),
        ]),
        {'fry', 'farnsworth'},
      );
    });

    test('a group of one should act as that clause', () async {
      expect(
        await namesWhere([
          Clause.or([Clause(TestUser.fieldName, isEqualTo: 'leela')]),
        ]),
        {'leela'},
      );
    });

    test('should refuse an empty group', () {
      expect(() => Clause.or(const []), throwsArgumentError);
      expect(() => Clause.and(const []), throwsArgumentError);
    });

    test('countWhere should count OR matches', () async {
      expect(
        await users.countWhere([
          Clause.or([
            Clause(TestUser.fieldName, isEqualTo: 'fry'),
            Clause(TestUser.fieldName, isEqualTo: 'leela'),
          ]),
        ]),
        2,
      );
    });

    test('should leave the order alone when only groups filter', () {
      final orderBy = [OrderBy(field: TestUser.fieldName)];
      final query = FirefuelQuery(
        clauses: [
          Clause.or([
            Clause(TestUser.fieldAge, isLessThan: 10),
            Clause(TestUser.fieldAge, isGreaterThan: 100),
          ]),
        ],
        orderBy: orderBy,
      );

      expect(query.effectiveOrderBy, orderBy);
    });
  });

  group('aggregate', () {
    test('should compute count, sums and averages in one call', () async {
      final result = await users.aggregate(
        FirefuelQuery(clauses: [Clause(TestUser.fieldAge, isLessThan: 100)]),
        count: true,
        sums: [TestUser.fieldAge],
        averages: [TestUser.fieldAge],
      );

      expect(result.count, 4);
      expect(result.sums[TestUser.fieldAge], 81);
      expect(result.averages[TestUser.fieldAge], closeTo(81 / 4, 1e-9));
    });

    test('should leave count null when not requested', () async {
      final result = await users.aggregate(
        FirefuelQuery(),
        sums: [TestUser.fieldAge],
      );

      expect(result.count, isNull);
      expect(result.sums[TestUser.fieldAge], 241);
    });

    test('should refuse a request for nothing', () {
      expect(() => users.aggregate(FirefuelQuery()), throwsArgumentError);
    });

    test('the repository should wrap the result', () async {
      final repository = TestRepository(collection: users);

      final result = await repository.aggregate(FirefuelQuery(), count: true);

      expect(result.getRightOrElseNull()?.count, 5);
    });
  });
}
