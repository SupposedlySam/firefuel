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
    Null Function()? onDelete,
    List<T> Function()? onLimit,
    Stream<T?> Function()? onListen,
    Stream<List<T>> Function()? onListenAll,
    Stream<List<T>> Function()? onListenLimited,
    Stream<List<T>> Function()? onListenOrdered,
    Stream<List<T>> Function()? onListenWhere,
    List<T> Function()? onOrderBy,
    Chunk<T> Function()? onPaginate,
    T? Function()? onRead,
    List<T>? Function()? onReadAll,
    T Function()? onReadOrCreate,
    Null Function()? onReplace,
    Null Function()? onReplaceFields,
    Null Function()? onUpdate,
    T Function()? onUpdateOrCreate,
    List<T> Function()? onWhere,
  }) {
    registerFallbackValue(DocumentId('fallbackValue'));
    registerFallbackValue<Serializable>(TestUser('fallbackValue'));
    registerFallbackValue(Chunk<TestUser>(orderBy: [
      OrderBy.string(
        field: TestUser.fieldName,
      )
    ]));

    if (onCreate != null) {
      when(() => create(any())).thenAnswer((_) => Future.value(onCreate()));
    }

    if (onCreateById != null) {
      when(() {
        return createById(
          docId: any(named: 'docId'),
          value: any(named: 'value'),
        );
      }).thenAnswer((_) => Future.value(onCreateById()));
    }

    if (onDelete != null) {
      when(() => delete(any())).thenAnswer((_) => Future.value(onDelete()));
    }

    if (onLimit != null) {
      when(() => limit(any())).thenAnswer((_) => Future.value(onLimit()));
    }

    if (onListen != null) {
      when(() => listen(any())).thenAnswer((_) => onListen());
    }

    if (onListenAll != null) {
      when(() => listenAll()).thenAnswer((_) => onListenAll());
    }

    if (onListenLimited != null) {
      when(() => listenLimited(any())).thenAnswer((_) => onListenLimited());
    }

    if (onListenOrdered != null) {
      when(() => listenOrdered(any())).thenAnswer((_) => onListenOrdered());
    }

    if (onListenWhere != null) {
      when(() {
        return listenWhere(any(), limit: any(named: 'limit'));
      }).thenAnswer(
        (_) => onListenWhere(),
      );
    }

    if (onOrderBy != null) {
      when(() => orderBy(
            any(),
            limit: any(named: 'limit'),
          )).thenAnswer((_) => Future.value(onOrderBy()));
    }

    if (onPaginate != null) {
      when(() => paginate(any())).thenAnswer((_) => Future.value(onPaginate()));
    }

    if (onRead != null) {
      when(() => read(any())).thenAnswer((_) => Future.value(onRead()));
    }

    if (onReadAll != null) {
      when(() => readAll()).thenAnswer((_) => Future.value(onReadAll()));
    }

    if (onReadOrCreate != null) {
      when(() {
        return readOrCreate(
          createValue: any(named: 'createValue'),
          docId: any(named: 'docId'),
        );
      }).thenAnswer((_) => Future.value(onReadOrCreate()));
    }

    if (onReplace != null) {
      when(() {
        return replace(
          docId: any(named: 'docId'),
          value: any(named: 'value'),
        );
      }).thenAnswer((_) => Future.value(onReplace()));
    }

    if (onReplaceFields != null) {
      when(() {
        return replaceFields(
          docId: any(named: 'docId'),
          value: any(named: 'value'),
          fieldPaths: any(named: 'fieldPaths'),
        );
      }).thenAnswer((_) => Future.value(onReplaceFields()));
    }

    if (onUpdate != null) {
      when(() => update(docId: any(named: 'docId'), value: any(named: 'value')))
          .thenAnswer((_) => Future.value(onUpdate()));
    }

    if (onUpdateOrCreate != null) {
      when(() {
        return updateOrCreate(
          docId: any(named: 'docId'),
          value: any(named: 'value'),
        );
      }).thenAnswer((_) => Future.value(onUpdateOrCreate()));
    }

    if (onWhere != null) {
      when(() {
        return where(any(), limit: any(named: 'limit'));
      }).thenAnswer((_) => Future.value(onWhere()));
    }
  }
}
