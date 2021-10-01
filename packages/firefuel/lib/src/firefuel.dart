import 'package:cloud_firestore/cloud_firestore.dart';

class Firefuel {
  static FirebaseFirestore get firestore {
    assert(_firestore != null, 'Firefuel is not initialized');
    return _firestore!;
  }

  static FirebaseFirestore? _firestore;

  static String get env {
    if (_env == null) return '';
    return '$_env-';
  }

  static String? _env;

  /// Initializes Firefuel with instance of [FirebaseFirestore]
  ///
  /// This method must be called before any other method of Firefuel
  ///
  /// All collections will reference [firestore]
  ///
  /// ---
  ///
  /// [env] is optional and will be prepended to all collection names
  ///
  /// Useful for separating collections between app flavors / environments
  static void initialize(
    FirebaseFirestore firestore, {
    String? env,
  }) {
    _firestore = firestore;
    _env = env;
  }
}
