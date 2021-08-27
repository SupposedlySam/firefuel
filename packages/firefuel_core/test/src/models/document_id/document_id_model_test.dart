import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:firefuel_core/src/models/document_id/document_id_model.dart';
import 'package:test/test.dart';

void main() {
  test('should remove all forward from input', () {
    final docId = DocumentId('some/string/with/forward/slashes');

    expect(docId.docId, 'somestringwithforwardslashes');
  });

  group('should throw', () {
    test(
      '$CannotBeNoLongerThan1500Bytes when the input is longer than 1500 bytes',
      () {
        // Generate a random lowercase string that's 1501 bytes in length
        final invalidInput = utf8.decode(
          Uint8List.fromList(
            List.generate(
              1501,
              // Lowercase a-z is 97 - 122 in utf-8
              // See the result of utf8.encode('a') and utf8.encode('z')
              (_) => (Random().nextDouble() * 25).toInt() + 97,
            ),
          ),
        );

        expect(
          () => DocumentId(invalidInput),
          throwsA(isA<CannotBeNoLongerThan1500Bytes>()),
        );
      },
    );

    test('$CannotSolelyConsistOfASingleOrDoublePeriod when value is "."', () {
      final invalidInput = '.';

      expect(
        () => DocumentId(invalidInput),
        throwsA(isA<CannotSolelyConsistOfASingleOrDoublePeriod>()),
      );
    });

    test('$CannotSolelyConsistOfASingleOrDoublePeriod when value is "."', () {
      final invalidInput = '..';

      expect(
        () => DocumentId(invalidInput),
        throwsA(isA<CannotSolelyConsistOfASingleOrDoublePeriod>()),
      );
    });

    test(
      '$CannotStartAndEndWithDoubleUnderscore when value matches regex "__.*__"',
      () {
        expect(
          () => DocumentId('__someValue__'),
          throwsA(isA<CannotStartAndEndWithDoubleUnderscore>()),
        );
        expect(
          () => DocumentId('____'),
          throwsA(isA<CannotStartAndEndWithDoubleUnderscore>()),
        );
        expect(
          () => DocumentId('__1234__'),
          throwsA(isA<CannotStartAndEndWithDoubleUnderscore>()),
        );
        expect(
          () => DocumentId('__  __'),
          throwsA(isA<CannotStartAndEndWithDoubleUnderscore>()),
        );
      },
    );

    test(
      '$CannotContainForwardSlash when forward slash is present and flag is set',
      () {
        final invalidInput = 'some/value';

        expect(
          () => DocumentId(invalidInput, throwsOnForwardSlash: true),
          throwsA(isA<CannotContainForwardSlash>()),
        );
      },
    );
  });
}
