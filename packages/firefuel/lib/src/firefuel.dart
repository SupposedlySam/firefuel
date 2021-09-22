import 'package:cloud_firestore/cloud_firestore.dart';

class Firefuel {
  const Firefuel._();

  static FirebaseFirestore get firestore {
    assert(_firestore != null, 'Firefuel is not initialized');
    return _firestore!;
  }

  static FirebaseFirestore? _firestore;

  static String get collectionPrefix {
    if (_collectionPrefix == null) return '';
    return '$_collectionPrefix-';
  }

  static String? _collectionPrefix;

  /// Initializes Firefuel with instance of [FirebaseFirestore]
  ///
  /// This method must be called before any other method of Firefuel
  ///
  /// All collections will reference [firestore]
  ///
  /// ---
  ///
  /// [collectionPrefix] is optional and will be prepended to all collection names
  ///
  /// Useful for separating collections between app flavors / environments
  static void initialize(
    FirebaseFirestore firestore, {
    String? collectionPrefix,
  }) {
    _firestore = firestore;
    _collectionPrefix = collectionPrefix;
  }
}
