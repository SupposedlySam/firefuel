import 'package:firefuel/firefuel.dart';

import '__DOCUMENT_NAME__snake.dart';
import '__DOCUMENT_NAME__snake_collection.dart';

/// Business logic for your __DOCUMENT_NAME__pascal data, with every
/// collection method returning `Either<Failure, T>` instead of throwing.
///
/// For instance, a `delete` that removes a message both locally and
/// remotely belongs here, so the rest of your app does not need to know
/// how the data is stored.
class __DOCUMENT_NAME__pascalRepository extends FirefuelRepository<__DOCUMENT_NAME__pascal> {
  __DOCUMENT_NAME__pascalRepository(this.__DOCUMENT_NAME__camelCollection)
    : super(collection: __DOCUMENT_NAME__camelCollection);

  final __DOCUMENT_NAME__pascalCollection __DOCUMENT_NAME__camelCollection;
}
