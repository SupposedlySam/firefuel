import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel_core/firefuel_core.dart';

import 'package:firefuel/src/rules.dart';

abstract class Collection<T extends Serializable>
    implements
        CollectionRead<List<T>, T>,
        DocCreate<DocumentId, T>,
        DocCreateIfNotExist<T, T>,
        DocDelete<Null>,
        DocRead<T?>,
        DocReplace<Null, T>,
        DocUpdate<Null, T> {
  const Collection();

  CollectionReference<T?> get ref;

  Stream<List<T>> get stream;
}
