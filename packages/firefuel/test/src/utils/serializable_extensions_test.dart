import 'package:firefuel/src/utils/serializable_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/test_user.dart';

void main() {
  group('#getReplacement', () {
    final testUser = TestUser('Asian Jim');

    test('should return an empty map when no field paths provided', () {
      final fieldPaths = <String>[];
      final expected = {};
      final actual = testUser.getReplacement(fieldPaths);

      expect(actual, expected);
    });

    test('should return key & value for name field when provided', () {
      final fieldPaths = <String>[TestUser.fieldName];
      final expected = {'name': 'Asian Jim'};
      final actual = testUser.getReplacement(fieldPaths);

      expect(actual, expected);
    });

    test('should return an empty map when fields are wrongly formatted', () {
      final fieldPaths = <String>['Name', 'Age'];
      final expected = {};
      final actual = testUser.getReplacement(fieldPaths);

      expect(actual, expected);
    });
  });
}
