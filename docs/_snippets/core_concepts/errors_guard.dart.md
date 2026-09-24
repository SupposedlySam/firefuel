```dart
Future<Either<Failure, T?>> read(DocumentId docId) {
  return guard(() => _collection.read(docId));
}
```
