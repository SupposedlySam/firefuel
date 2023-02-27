import 'package:firefuel/firefuel.dart';

import './{{#snakeCase}}{{{document_name}}}{{/snakeCase}}.dart';

class {{#pascalCase}}{{{document_name}}}{{/pascalCase}}Collection
    extends FirefuelCollection<{{#pascalCase}}{{{document_name}}}{{/pascalCase}}> {
  {{#pascalCase}}{{{document_name}}}{{/pascalCase}}Collection() : super(collectionName);

  static const collectionName = '__COLLECTION_NAME__';

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
  Map<String, Object?> toFirestore(
      {{#pascalCase}}{{{document_name}}}{{/pascalCase}}? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
