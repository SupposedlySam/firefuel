import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/firefuel_collection/firefuel_collection_base.dart';
import 'package:firefuel/src/firefuel_collection/firefuel_collection_offline.dart';
import 'package:firefuel/src/firefuel_collection/firefuel_collection_online.dart';

abstract class FirefuelCollection<T extends Serializable>
    extends FirefuelCollectionBase<T> implements Collection<T> {
  final String path;

  final FirebaseFirestore firestore;

  late FirefuelCollectionBase<T> onlineImpl;

  late FirefuelCollectionBase<T> offlineImpl;

  late CollectionReference<T?> _typedRef;

  FirefuelCollection(
    String path, {
    bool useEnv = true,
    FirefuelCollectionBase<T>? onlineImpl,
    FirefuelCollectionBase<T>? offlineImpl,
  })  : this.path = _buildPath(path, useEnv),
        this.firestore = Firefuel.firestore,
        super(_buildUntypedRef(Firefuel.firestore, _buildPath(path, useEnv))) {
    this._typedRef = untypedRef.withConverter(
      fromFirestore: fromFirestore,
      toFirestore: toFirestore,
    );
    this.onlineImpl =
        onlineImpl ?? FirefuelCollectionOnline<T>(untypedRef, _typedRef);
    this.offlineImpl =
        offlineImpl ?? FirefuelCollectionOffline<T>(untypedRef, _typedRef);
  }

  @override
  CollectionReference<T?> get ref => _typedRef;

  @override
  Future<DocumentId> create(T value) async {
    return Firefuel.isOnline
        ? onlineImpl.create(value)
        : offlineImpl.create(value);
  }

  @override
  Future<DocumentId> createById({
    required T value,
    required DocumentId docId,
  }) async {
    return Firefuel.isOnline
        ? onlineImpl.createById(value: value, docId: docId)
        : offlineImpl.createById(value: value, docId: docId);
  }

  @override
  Future<Null> delete(DocumentId docId) async {
    return Firefuel.isOnline
        ? onlineImpl.delete(docId)
        : offlineImpl.delete(docId);
  }

  /// Converts a [DocumentSnapshot] to a [T?]
  T? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  @override
  Future<List<T>> limit(int limit) async {
    return Firefuel.isOnline
        ? onlineImpl.limit(limit)
        : offlineImpl.limit(limit);
  }

  @override
  Future<List<T>> orderBy(List<OrderBy> orderBy, {int? limit}) async {
    return Firefuel.isOnline
        ? onlineImpl.orderBy(orderBy, limit: limit)
        : offlineImpl.orderBy(orderBy, limit: limit);
  }

  @override
  Future<Chunk<T>> paginate(Chunk<T> chunk) async {
    return Firefuel.isOnline
        ? onlineImpl.paginate(chunk)
        : offlineImpl.paginate(chunk);
  }

  @override
  Future<T?> read(DocumentId docId) async {
    return Firefuel.isOnline ? onlineImpl.read(docId) : offlineImpl.read(docId);
  }

  @override
  Future<List<T>> readAll() async {
    return Firefuel.isOnline ? onlineImpl.readAll() : offlineImpl.readAll();
  }

  @override
  Future<T> readOrCreate({
    required DocumentId docId,
    required T createValue,
  }) async {
    return Firefuel.isOnline
        ? onlineImpl.readOrCreate(docId: docId, createValue: createValue)
        : offlineImpl.readOrCreate(docId: docId, createValue: createValue);
  }

  @override
  Future<Null> replace({
    required DocumentId docId,
    required T value,
  }) async {
    return Firefuel.isOnline
        ? onlineImpl.replace(docId: docId, value: value)
        : offlineImpl.replace(docId: docId, value: value);
  }

  @override
  Future<Null> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  }) async {
    return Firefuel.isOnline
        ? onlineImpl.replaceFields(
            docId: docId, value: value, fieldPaths: fieldPaths)
        : offlineImpl.replaceFields(
            docId: docId, value: value, fieldPaths: fieldPaths);
  }

  /// Converts a [T?] to a [Map<String, Object?>] to upload to Firestore.
  Map<String, Object?> toFirestore(
    T? model,
    SetOptions? options,
  );

  @override
  Future<Null> update({
    required DocumentId docId,
    required T value,
  }) async {
    return Firefuel.isOnline
        ? onlineImpl.update(docId: docId, value: value)
        : offlineImpl.update(docId: docId, value: value);
  }

  @override
  Future<T> updateOrCreate({
    required DocumentId docId,
    required T value,
  }) async {
    return Firefuel.isOnline
        ? onlineImpl.updateOrCreate(docId: docId, value: value)
        : offlineImpl.updateOrCreate(docId: docId, value: value);
  }

  @override
  Future<List<T>> where(
    List<Clause> clauses, {
    List<OrderBy>? orderBy,
    int? limit,
  }) async {
    return Firefuel.isOnline
        ? onlineImpl.where(clauses, orderBy: orderBy, limit: limit)
        : offlineImpl.where(clauses, orderBy: orderBy, limit: limit);
  }

  @override
  Future<T?> whereById(DocumentId docId) async {
    return Firefuel.isOnline
        ? onlineImpl.whereById(docId)
        : offlineImpl.whereById(docId);
  }

  /// Prefix the collection path with the environment
  ///
  /// if the environment isn't provided, the path is returned unaltered.
  static String _buildPath(String path, bool useEnv) {
    if (useEnv) return '${Firefuel.env}$path';

    return path;
  }

  static _buildUntypedRef(FirebaseFirestore firestore, String path) =>
      firestore.collection(path);
}
