import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';

void main() {
  final rangeComparisons = [
    Clause('age', isLessThan: 20),
    Clause('age', isLessThanOrEqualTo: 20),
    Clause('age', isGreaterThan: 20),
    Clause('age', isGreaterThanOrEqualTo: 20),
  ];

  final equalityOrInComparisons = [
    Clause('name', isEqualTo: 'Trinity'),
    Clause('name', whereIn: ['Smith', 'Anderson']),
    Clause('name', isNull: true),
  ];

  group('.hasRangeComparison', () {
    test('should return true when using range comparison', () {
      for (final clause in rangeComparisons) {
        final result = Clause.hasRangeComparison([clause]);

        expect(result, isTrue);
      }
    });
  });

  group('.hasEqualityOrInComparison', () {
    test('should return true when using equality or in comparison', () {
      for (final clause in equalityOrInComparisons) {
        final result = Clause.hasEqualityOrInComparison([clause]);

        expect(result, isTrue);
      }
    });
  });

  group('.hasMoreThanOneFieldInRangeComparisons', () {
    test(
      'should return true when given more than one field in range comparison',
      () {
        final result = Clause.hasMoreThanOneFieldInRangeComparisons([
          Clause('age', isLessThan: 20),
          Clause('birthYear', isLessThan: 2000),
        ]);

        expect(result, isTrue);
      },
    );

    test(
      'should return false when given one field in range comparison',
      () {
        final result = Clause.hasMoreThanOneFieldInRangeComparisons([
          Clause('age', isLessThan: 20),
          Clause('age', isGreaterThan: 10),
        ]);

        expect(result, isFalse);
      },
    );
  });

  group('.getEqualityOrInComparisonFields', () {
    test('should filter out all non-equality or in comparison fields', () {
      const String equalToAge = 'age1', whereInAge = 'age2', nullAge = 'age3';

      final clauses = [
        Clause('age4', isNotEqualTo: 20),
        Clause('age5', isLessThan: 20),
        Clause('age6', isLessThanOrEqualTo: 20),
        Clause('age7', isGreaterThan: 20),
        Clause('age8', isGreaterThanOrEqualTo: 20),
        Clause('age9', arrayContains: 20),
        Clause('age10', arrayContainsAny: [20]),
        Clause('age11', whereNotIn: [20]),
        Clause(equalToAge, isEqualTo: 20),
        Clause(whereInAge, whereIn: [20]),
        Clause(nullAge, isNull: true),
      ];

      final result = Clause.getEqualityOrInComparisonFields(clauses);

      expect(result, [equalToAge, whereInAge, nullAge]);
    });
  });
}
