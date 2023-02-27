import 'package:firefuel/firefuel.dart';

import './__DOCUMENT_NAME__snake.dart';

class __DOCUMENT_NAME__pascalCollection
    extends FirefuelCollection<__DOCUMENT_NAME__pascal> {
  __DOCUMENT_NAME__pascalCollection() : super(collectionName);

  static const collectionName = '__COLLECTION_NAME__';

  @override
  __DOCUMENT_NAME__? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return data == null
        ? null
        : __DOCUMENT_NAME__.fromJson(snapshot.data()!, snapshot.id);
  }

  @override
  Map<String, Object?> toFirestore(
      __DOCUMENT_NAME__pascal? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
