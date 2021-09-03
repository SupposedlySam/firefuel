import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel_core/firefuel_core.dart';

abstract class Collection<T extends Serializable> {
  const Collection();

  CollectionReference<T?> get collectionRef;

  /// Exposes the Typed Stream from the Collection
  ///
  /// Use the [listen] method to implement this getter
  ///
  ///### Example
  ///#### Stream a top level collection
  /// ```
  /// Stream<List<YourType>> get stream => listen(collectionRef);
  /// ```
  ///
  /// #### Stream a subcollection
  ///
  /// ```
  /// Stream<List<T>> streamSubcollection<T>(CollectionReference<T> collectionReference) {
  ///   return listen<T>(collectionReference);
  /// }
  /// ```
  Stream<List<T>> get stream;

  /// Create a new document with an auto-generated [DocumentId]
  Future<DocumentId> create(T value);

  /// Create a new document with the provided [docId]
  Future<Null> createById({
    required T value,
    required DocumentId docId,
  });

  /// Deletes the current document from the collection.
  Future<Null> delete(DocumentId docId);

  /// Get the document by id, or create a new one
  ///
  /// If the documentId returns a snapshot that does not exist, or `data()`
  /// returns `null`, create a new document with the [docId] provided.
  Future<T> readOrCreate({
    required DocumentId docId,
    required T createValue,
  });

  /// Get a document from the collection
  ///
  /// Refreshes automatically when new data is added to the document
  ///
  /// See: StreamBuilder
  Stream<T?> listen<T>(
    CollectionReference<T> collectionRef,
    DocumentId docId,
  );

  /// Get a list of all documents from the collection as a list
  ///
  /// Refreshes automatically when new data is added to the collection
  ///
  /// See: StreamBuilder
  Stream<List<T>> listenAll<T>(CollectionReference<T> collectionRef);

  /// Gets a single document from the collection
  ///
  /// Does NOT refresh automatically
  Future<T?> read(DocumentId docId);

  /// Gets a stream of the document requested
  Stream<T?> readAsStream(DocumentId docId);

  /// Updates data on the document. Data will be merged with any existing
  /// document data.
  ///
  /// If no document exists yet, the update will fail.
  Future<Null> update({
    required DocumentId docId,
    required T value,
  });

  /// Updates data on the document if it exists. Data will be merged with
  /// any existing document data.
  ///
  /// If no document exists, a new document will be created
  Future<Null> updateOrCreate({
    required DocumentId docId,
    required T value,
  });
}