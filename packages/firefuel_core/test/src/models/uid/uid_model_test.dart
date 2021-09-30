import 'package:test/test.dart';

import 'package:firefuel_core/src/models/uid/uid_model.dart';

void main() {
  test('should store unmodified input', () {
    final original = 'some/string/with\multiple/bad\slashes\in\it';
    final uid = UID(original);

    expect(uid.uid, original);
  });
}
