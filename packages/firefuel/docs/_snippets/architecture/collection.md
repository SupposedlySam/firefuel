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

    // If you want your model to contain the DocumentId, make your `fromJson` 
    // function accept the `snapshot.id` and assign it as a property on your model!
    return YourModel.fromJson(snapshot.data()!, snapshot.id); 
  }

  @override
  Map<String, Object?> toFirestore(YourModel? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
```
