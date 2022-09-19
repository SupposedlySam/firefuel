import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';

void main() {
  const String testField = 'testField';
  group('$OrderBy', () {
    group('@docId', () {
      test('should set byId to true ', () {
        final instance = OrderBy.docId(OrderDirection.aToZ);

        expect(instance.byId, isTrue);
      });
    });

    test('should set direction to asc when newestToOldest is chosen', () {
      final instance = OrderBy(
        field: testField,
        direction: OrderDirection.newestToOldest,
      );

      expect(instance.direction, OrderDirection.asc);
    });

    test('should set direction to desc when oldestToNewest is chosen', () {
      final instance = OrderBy(
        field: testField,
        direction: OrderDirection.oldestToNewest,
      );

      expect(instance.direction, OrderDirection.desc);
    });

    test('should set direction to asc when falseToTrue is chosen', () {
      final instance = OrderBy(
        field: testField,
        direction: OrderDirection.falseToTrue,
      );

      expect(instance.direction, OrderDirection.asc);
    });

    test(
      'should set direction to desc when trueToFalse is chosen',
      () {
        final instance = OrderBy(
          field: testField,
          direction: OrderDirection.trueToFalse,
        );

        expect(instance.direction, OrderDirection.desc);
      },
    );

    test('should set direction to asc when smallestToLargest is chosen', () {
      final instance = OrderBy(
        field: testField,
        direction: OrderDirection.smallestToLargest,
      );

      expect(instance.direction, OrderDirection.asc);
    });

    test(
      'should set direction to desc when largestToSmallest is chosen',
      () {
        final instance = OrderBy(
          field: testField,
          direction: OrderDirection.largestToSmallest,
        );

        expect(instance.direction, OrderDirection.desc);
      },
    );

    test('should set direction to asc when aToZ is chosen', () {
      final instance = OrderBy(
        field: testField,
        direction: OrderDirection.aToZ,
      );

      expect(instance.direction, OrderDirection.asc);
    });

    test('should set direction to desc when zToA is chosen', () {
      final instance = OrderBy(
        field: testField,
        direction: OrderDirection.zToA,
      );

      expect(instance.direction, OrderDirection.desc);
    });
  });

  group('.removeEqualityAndInMatchingFields', () {
    test('should return empty list when all OrderBys are matching', () {
      final orderByName = OrderBy(field: 'name');

      final result = OrderBy.removeEqualtyAndInMatchingFields(
        fieldsToMatch: ['name'],
        orderBy: [orderByName],
        isEqualityOrInComparison: true,
      );

      expect(result, isEmpty);
    });

    test('should return sublist when some OrderBys are matching', () {
      final orderByAge = OrderBy(field: 'age');
      final orderByName = OrderBy(field: 'name');

      final result = OrderBy.removeEqualtyAndInMatchingFields(
        fieldsToMatch: ['name'],
        orderBy: [orderByAge, orderByName],
        isEqualityOrInComparison: true,
      );

      expect(result, [orderByAge]);
    });
  });

  group('.moveOrCreateMatchingField', () {
    test('should move $OrderBy when it exists but is not first', () {
      final orderByAge = OrderBy(field: 'age');
      final orderByName = OrderBy(field: 'name');

      final result = OrderBy.moveOrCreateMatchingField(
        fieldToMatch: 'name',
        orderBy: [orderByAge, orderByName],
        isRangeComparison: true,
      );

      expect(result, [orderByName, orderByAge]);
    });

    test('should create $OrderBy when it does not exist', () {
      final orderByAge = OrderBy(field: 'age');
      final orderByName = OrderBy(field: 'name');

      final result = OrderBy.moveOrCreateMatchingField(
        fieldToMatch: 'name',
        orderBy: [orderByAge],
        isRangeComparison: true,
      );

      expect(result, [orderByName, orderByAge]);
    });
  });
}
