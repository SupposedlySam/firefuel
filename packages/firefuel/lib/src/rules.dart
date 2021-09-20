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
  /// Refreshes automatically when new data is added/removed from the collection
  ///
  /// See: StreamBuilder
  Stream<R> listenAll();

  /// Get up to the maximum number of documents specified by the [limit]
  ///
  /// Returns 0 to [limit]
  Future<R> limit(int limit);

  /// Get up to the maximum number of documents specified by the [limit]
  ///
  /// Refreshes automatically when new data is added/removed from the
  /// collection
  Stream<R> listenLimited(int limit);

  /// Get a list of documents matching all clauses
  ///
  /// limit: optionally provide a maximum value of items to be returned
  ///
  /// throws a [MissingValueException] when no [Clause]s are given
  Future<R> where(List<Clause> clauses, {int? limit});

  /// Get a list of documents matching all clauses
  ///
  /// Refreshes automatically when new matching data is added/removed from the
  /// collection
  ///
  /// limit: optionally provide a maximum value of items to be returned
  ///
  /// throws a [MissingValueException] when no [Clause]s are given
  Stream<R> listenWhere(List<Clause> clauses, {int? limit});

  /// Gets all documents from the collection
  ///
  /// Does NOT refresh automatically
  ///
  /// Related: [listenAll]
  ///
  /// {@macro firefuel.rules.subclasses}
  /// {@macro firefuel.rules.implementations}
  Future<R> readAll();
}

/// Get a number of Documents from the Collection
///
/// /// [R]: should return a [T] or some subset,
/// i.e. `Either<Failure, T>`
///
/// {@macro firefuel.rules.subclasses}
/// {@macro firefuel.rules.implementations}
abstract class CollectionPaginate<R, T extends Serializable> {
  /// Get a number of Documents from the Collection specified by the [chunk]
  ///
  /// Store the [Chunk] you get back from calling this method and pass it back
  /// to the [paginate] method to get the next [Chunk]
  ///
  /// You can continue to do this until the `Chunk.status` equals
  /// [ChunkStatus.last].
  ///
  /// Passing in a [Chunk] with the status of [ChunkStatus.last] will result in
  /// a [Chunk] with empty data.
  Future<R> paginate(Chunk<T> chunk);
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
  /// The value returned is the value passed in, a read is not performed
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
