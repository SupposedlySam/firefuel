import 'dart:async';

import 'package:mocktail/mocktail.dart';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/collection.dart';
import '../utils/test_user.dart';

class MockCollection<T extends Serializable> extends Mock
    implements Collection<T> {}

extension MockCollectionX<T extends Serializable> on MockCollection<T> {
  void initialize({
    DocumentId Function()? onCreate,
    DocumentId Function()? onCreateById,
    T? Function()? onRead,
    Stream<T?> Function()? onListen,
    Stream<List<T>> Function()? onListenAll,
    Null Function()? onUpdate,
    Null Function()? onDelete,
  }) {
    registerFallbackValue(DocumentId('fallbackValue'));
    registerFallbackValue<Serializable>(TestUser('fallbackValue'));

    if (onCreate != null) {
      when(() => create(any())).thenAnswer((_) => Future.value(onCreate()));
    }

    if (onCreateById != null) {
      when(
        () => createById(
          docId: any(named: 'docId'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) => Future.value(onCreateById()));
    }

    if (onRead != null) {
      when(() => read(any())).thenAnswer((_) => Future.value(onRead()));
    }

    if (onListen != null) {
      when(() => listen(any())).thenAnswer((_) => onListen());
    }

    if (onListenAll != null) {
      when(() => listenAll()).thenAnswer((_) => onListenAll());
    }

    if (onUpdate != null) {
      when(() => update(docId: any(named: 'docId'), value: any(named: 'value')))
          .thenAnswer((_) => Future.value(onUpdate()));
    }

    if (onDelete != null) {
      when(() => delete(any())).thenAnswer((_) => Future.value(onDelete()));
    }
  }
}
