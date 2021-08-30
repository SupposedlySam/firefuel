import 'dart:async';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/collection.dart';
import 'package:mocktail/mocktail.dart';

import '../utils/test_user.dart';

class MockCollection<T extends Serializable?> extends Mock
    implements Collection<T> {}

extension MockCollectionX<T extends Serializable?> on MockCollection<T> {
  void initialize({
    DocumentId Function()? onCreate,
    T? Function()? onRead,
    Null Function()? onUpdate,
  }) {
    registerFallbackValue(DocumentId('fallbackValue'));
    registerFallbackValue<Serializable>(TestUser('fallbackValue'));

    if (onCreate != null) {
      when(
        () => create(docId: any(named: 'docId'), value: any(named: 'value')),
      ).thenAnswer((_) => Future.value(onCreate()));
    }

    if (onRead != null) {
      when(() => read(any())).thenAnswer((_) => Future.value(onRead()));
    }

    if (onUpdate != null) {
      when(() => update(docId: any(named: 'docId'), value: any(named: 'value')))
          .thenAnswer((_) => Future.value(onUpdate()));
    }
  }
}