import 'package:firefuel/firefuel.dart';

import './__DOCUMENT_NAME__snake.dart';
import './__DOCUMENT_NAME__snake_collection.dart';

/// Used to encapsulate business logic for your data layer
///
/// For instance, you can create a method called `delete` on a
/// `MessageRepository`. The Repository would be responsible for deleting the
/// message both locally, and remotely. The rest of your application
/// doesn't need to worry about the data implementation detail.
///
/// Additionally, you may need to use multiple methods from your collection
/// to successfully perform an action you commonly use. Combining those actions
/// into one method means you don't have to duplicate the same logic elsewhere.
class __DOCUMENT_NAME__pascalRepositoryImpl
    extends FirefuelRepository<__DOCUMENT_NAME__pascal> {
  __DOCUMENT_NAME__pascalRepositoryImpl(this.__DOCUMENT_NAME__camelCollection)
      : super(collection: __DOCUMENT_NAME__camelCollection);

  final __DOCUMENT_NAME__pascalCollection __DOCUMENT_NAME__camelCollection;
}
