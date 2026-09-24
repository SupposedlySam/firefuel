import 'package:firefuel_core/firefuel_core.dart';
import 'package:test/test.dart';

void main() {
  group('$FieldUpdate equality', () {
    test('should equal the same variant with the same values', () {
      expect(const FieldUpdate.increment(2), const FieldUpdate.increment(2));
      expect(
        const FieldUpdate.arrayUnion(['a']),
        const FieldUpdate.arrayUnion(['a']),
      );
      expect(const FieldUpdate.serverTimestamp(), const ServerTimestamp());
    });

    // equatable 3 stopped comparing runtimeType. These pairs have identical
    // props apart from the variant, so they must stay distinct on either
    // major version.
    test('should tell variants with the same values apart', () {
      expect(const FieldUpdate.delete(), isNot(const ServerTimestamp()));
      expect(
        const FieldUpdate.arrayUnion(['a']),
        isNot(const FieldUpdate.arrayRemove(['a'])),
      );
    });

    test('should tell different values apart', () {
      expect(
        const FieldUpdate.increment(1),
        isNot(const FieldUpdate.increment(2)),
      );
    });
  });
}
