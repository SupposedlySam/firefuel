import 'package:cloud_firestore/cloud_firestore.dart';

class Firefuel {
  const Firefuel._();

  static FirebaseFirestore get firestore {
    assert(_firestore != null, 'Firefuel is not initialized');
    return _firestore!;
  }

  static FirebaseFirestore? _firestore;

  /// Initializes Firefuel with instance of [FirebaseFirestore]
  ///
  /// This method must be called before any other method of Firefuel
  ///
  /// All collections will reference [firestore]
  static void initialize(FirebaseFirestore firestore) {
    _firestore = firestore;
  }
}
