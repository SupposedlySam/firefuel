import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firefuel/firefuel.dart';

/// Read a `List` of [T] from the Collection
///
/// [R]: should return a `List<T>` or some subset,
/// i.e. `Either<Failure, List<T>>`
///
/// {@template firefuel.rules.subclasses}
/// - Subclasses: [Collection] and [Repository] for subclasses
/// {@endtemplate}
/// {@template firefuel.rules.implementations}
/// - Implementations: [FirefuelCollection] and [FirefuelRepository] for subclasses
/// {@endtemplate}
abstract class CollectionRead<R, T extends Serializable> {
  /// Get a list of all documents from the collection as a list
  ///
  /// Refreshes automatically when new data is added to the collection
  ///
  /// See: StreamBuilder
  Stream<R> listenAll(CollectionReference<T> ref);
}

/// Create a new Document
///
/// [R]: should return a [DocumentId] or some subset,
/// i.e. `Either<Failure, DocumentId>`
///
/// {@macro firefuel.rules.subclasses}
/// {@macro firefuel.rules.implementations}
abstract class DocCreate<R, T extends Serializable> {
  /// Create a new document with an auto-generated [DocumentId]
  Future<R> create(T value);

  /// Create a new document with the provided [docId]
  Future<R> createById({
    required T value,
    required DocumentId docId,
  });
}

/// Do some action, then create a Document if it doesn't exist
///
/// [R]: should return a [T] or some subset,
/// i.e. `Either<Failure, T>`
///
/// {@macro firefuel.rules.subclasses}
/// {@macro firefuel.rules.implementations}
abstract class DocCreateIfNotExist<R, T extends Serializable> {
  /// Get the document by id, or create a new one
  ///
  /// If the documentId returns a snapshot that does not exist, or `data()`
  /// returns `null`, create a new document with the [docId] provided.
  Future<R> readOrCreate({
    required DocumentId docId,
    required T createValue,
  });

  /// Updates data on the document if it exists. Data will be merged with
  /// any existing document data.
  ///
  /// If no document exists, a new document will be created
  ///
  /// *Requires 1 read of doc to retrieve the new document*
  Future<R> updateOrCreate({
    required DocumentId docId,
    required T value,
  });
}

/// Delete an existing Document
///
/// [R]: should return [Null] or some subset,
/// i.e. `Either<Failure, Null>`
///
/// {@macro firefuel.rules.subclasses}
/// {@macro firefuel.rules.implementations}
abstract class DocDelete<R> {
  /// Deletes the current document from the collection.
  Future<R> delete(DocumentId docId);
}

/// Read a Document
///
/// [R]: should return a [T?] or some subset,
/// i.e. `Either<Failure, T?>`
///
/// {@macro firefuel.rules.subclasses}
/// {@macro firefuel.rules.implementations}
abstract class DocRead<R> {
  /// Gets a stream of the document requested
  Stream<R> listen(DocumentId docId);

  /// Gets a single document from the collection
  ///
  /// Does NOT refresh automatically
  Future<R> read(DocumentId docId);
}

/// Replace an existing Document
///
/// [R]: should return [Null] or some subset,
/// i.e. `Either<Failure, Null>`
///
/// {@macro firefuel.rules.subclasses}
/// {@macro firefuel.rules.implementations}
abstract class DocReplace<R, T extends Serializable> {
  /// Replaces the document at [docId] with [value].
  ///
  /// If no document exists yet, the replace will fail.
  ///
  /// *Requires 1 read of doc to perform replace*
  Future<R> replace({required DocumentId docId, required T value});

  /// Replaces the fields of the document at [docId] with the matching
  /// [fieldPaths] from [value]
  ///
  /// Converts all [fieldPaths] into [FieldPath] objects to compare against
  ///
  /// If no document exists yet, the update will fail silently.
  Future<R> replaceFields({
    required DocumentId docId,
    required T value,
    required List<String> fieldPaths,
  });
}

/// Update an existing Document
///
/// [R]: should return [Null] or some subset,
/// i.e. `Either<Failure, Null>`
///
/// {@macro firefuel.rules.subclasses}
/// {@macro firefuel.rules.implementations}
abstract class DocUpdate<R, T extends Serializable> {
  /// Updates data on the document. Data will be merged with any existing
  /// document data.
  ///
  /// If no document exists yet, the update will fail silently.
  Future<R> update({
    required DocumentId docId,
    required T value,
  });
}
