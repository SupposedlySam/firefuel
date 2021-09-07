```dart
class UserRepository extends FirefuelRepository<User> {
  UserRepository({
    required UserCollection topLevelCollection,
    required UserConversationCollection userConversationCollection,
  }) : super(collection: topLevelCollection);

  final UserCollection topLevelCollection;
  final UserConversationCollection userConversationCollection;

  Stream<List<Conversation>> get conversations {
    return userConversationCollection.stream;
  }
}
```