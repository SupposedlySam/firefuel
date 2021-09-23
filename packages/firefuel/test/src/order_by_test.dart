import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';

void main() {
  const String testField = 'testField';
  group('$OrderBy.date', () {
    test('should set direction to asc when newestToOldest is chosen', () {
      final instance = OrderBy.date(
        field: testField,
        orderBy: OrderByDate.newestToOldest,
      );

      expect(instance.direction, OrderDirection.asc);
    });

    test('should set direction to desc when oldestToNewest is chosen', () {
      final instance = OrderBy.date(
        field: testField,
        orderBy: OrderByDate.oldestToNewest,
      );

      expect(instance.direction, OrderDirection.desc);
    });
  });

  group('$OrderBy.bool', () {
    test('should set direction to asc when falseToTrue is chosen', () {
      final instance = OrderBy.bool(
        field: testField,
        orderBy: OrderByBool.falseToTrue,
      );

      expect(instance.direction, OrderDirection.asc);
    });

    test(
      'should set direction to desc when trueToFalse is chosen',
      () {
        final instance = OrderBy.bool(
          field: testField,
          orderBy: OrderByBool.trueToFalse,
        );

        expect(instance.direction, OrderDirection.desc);
      },
    );
  });

  group('$OrderBy.num', () {
    test('should set direction to asc when smallestToLargest is chosen', () {
      final instance = OrderBy.num(
        field: testField,
        orderBy: OrderByNum.smallestToLargest,
      );

      expect(instance.direction, OrderDirection.asc);
    });

    test(
      'should set direction to desc when largestToSmallest is chosen',
      () {
        final instance = OrderBy.num(
          field: testField,
          orderBy: OrderByNum.largestToSmallest,
        );

        expect(instance.direction, OrderDirection.desc);
      },
    );
  });

  group('$OrderBy.string', () {
    test('should set direction to asc when aToZ is chosen', () {
      final instance = OrderBy.string(
        field: testField,
        orderBy: OrderByString.aToZ,
      );

      expect(instance.direction, OrderDirection.asc);
    });

    test('should set direction to desc when zToA is chosen', () {
      final instance = OrderBy.string(
        field: testField,
        orderBy: OrderByString.zToA,
      );

      expect(instance.direction, OrderDirection.desc);
    });
  });
}
