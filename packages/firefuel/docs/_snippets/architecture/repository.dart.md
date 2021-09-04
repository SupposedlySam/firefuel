```dart
class YourRepository<T extends Serializable> extends FirefuelRepository<T> {
  YourRepository({required Collection<T> collection})
      : super(collection: collection);
}
```
