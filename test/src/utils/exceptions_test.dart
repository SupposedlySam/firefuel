import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';

void main() {
  group('$MissingValueException', () {
    test('should output Type when exception occurs', () {
      final exception = MissingValueException(String);

      expect(exception.toString(), 'MissingValueException:String');
    });
  });
}
