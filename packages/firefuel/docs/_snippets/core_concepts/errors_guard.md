```dart
  import 
  Future<Either<Failure, T?>> read(DocumentId docId) async {
    return guard(() => _collection.read(docId));
  }
```