import 'dart:async';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/serializable_extensions.dart';

class FirefuelBatch<T extends Serializable> extends Batch<T> {
  final FirefuelCollection<T> collection;

  FirefuelBatch(this.collection) : super(collection);

  @override
  Future<int?> create(T value) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<int?> createById({required T value, required DocumentId docId}) {
    // TODO: implement createById
    throw UnimplementedError();
  }

  @override
  Future<int?> delete(DocumentId docId) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<int?> replace({required DocumentId docId, required T value}) {
    // TODO: implement replace
    throw UnimplementedError();
  }

  @override
  Future<int?> replaceFields(
      {required DocumentId docId,
      required T value,
      required List<String> fieldPaths}) {
    // TODO: implement replaceFields
    throw UnimplementedError();
  }

  @override
  Future<int?> update({required DocumentId docId, required T value}) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
