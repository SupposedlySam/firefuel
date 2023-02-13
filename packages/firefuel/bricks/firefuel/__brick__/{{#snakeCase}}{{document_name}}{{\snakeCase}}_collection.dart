import 'package:firefuel/firefuel.dart';

import './{{document_name.snakeCase()}}.dart';

class {{document_name.pascalCase()}}Collection extends FirefuelCollection<{{document_name.pascalCase()}}> {
  {{document_name.pascalCase()}}Collection() : super(collectionName);

  static const collectionName = '{{collection_name.pascalCase().lowerCase()}}';

  @override
  {{document_name}}? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return data == null
        ? null
        : {{document_name}}.fromJson(snapshot.data()!, snapshot.id);
  }

  @override
  Map<String, Object?> toFirestore({{document_name.pascalCase()}}? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
