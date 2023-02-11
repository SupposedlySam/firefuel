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
    _env = env;
    _firestore = firestore;
  }

  /// Clears all local properties
  ///
  /// This is not required for normal use, but can be used if needing to reset
  ///  Firefuel
  static void reset() {
    _env = null;
    _firestore = null;
  }
}
