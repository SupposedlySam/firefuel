import 'package:firefuel/firefuel.dart';

import '{{#snakeCase}}{{{document_name}}}{{/snakeCase}}.dart';

class {{#pascalCase}}{{{document_name}}}{{/pascalCase}}Collection extends FirefuelCollection<{{#pascalCase}}{{{document_name}}}{{/pascalCase}}> {
  {{#pascalCase}}{{{document_name}}}{{/pascalCase}}Collection() : super(collectionName);

  static const collectionName = '{{{collection_name}}}';

  @override
  {{#pascalCase}}{{{document_name}}}{{/pascalCase}}? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return data == null ? null : {{#pascalCase}}{{{document_name}}}{{/pascalCase}}.fromJson(data, snapshot.id);
  }

  @override
  Map<String, Object?> toFirestore({{#pascalCase}}{{{document_name}}}{{/pascalCase}}? model, SetOptions? options) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
