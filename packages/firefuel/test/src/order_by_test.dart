import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';

void main() {
  const String testField = 'testField';
  group('$OrderBy', () {
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
  group('.removeEqualityAndInMatchingFields', () {}, skip: true);
  group('.moveOrCreateMatchingField', () {}, skip: true);
}
