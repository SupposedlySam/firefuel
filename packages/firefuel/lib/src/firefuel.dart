import 'package:cloud_firestore/cloud_firestore.dart';

class Firefuel {
  final FirebaseFirestore firestore;

  const Firefuel._(this.firestore);

  static Firefuel get instance {
    assert(_instance != null, 'Firefuel is not initialized');
    return _instance!;
  }

  static Firefuel? _instance;

  /// Initializes Firefuel with instance of [FirebaseFirestore]
  ///
  /// This method must be called before any other method of Firefuel
  ///
  /// All collections will reference [firestore]
  static void inititialize(FirebaseFirestore firestore) {
    _instance = Firefuel._(firestore);
  }
}
