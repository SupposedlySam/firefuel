```dart
class YourCollection extends FirefuelCollection<YourModel> {
  YourCollection() : super('yourCollectionName');

  @override
  YourModel? fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    if(data == null) return null;

    // Optional: You can add the document Id directly to the data your
    // Model is accepting.
    final dataWithId = { ...data, 'id': snapshot.id };

    return YourModel.fromJson(dataWithId);
  }

  @override
  Map<String, Object?> toFirestore(YourModel? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
```
