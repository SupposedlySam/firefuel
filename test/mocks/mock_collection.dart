import 'dart:async';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/collection.dart';
import 'package:mocktail/mocktail.dart';

class MockCollection<T extends Serializable> extends Mock
    implements Collection<T> {}

extension MockCollectionX<T extends Serializable> on MockCollection<T> {
  void initialize({Future<DocumentId>? createReturn}) {
    if (createReturn != null) {
      when(
        () => create(docId: any(named: 'docId'), value: any(named: 'value')),
      ).thenAnswer((_) => createReturn);
    }
  }
}
