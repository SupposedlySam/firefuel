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

  /// Allows for all functions to write to Firestore without "await"ing their
  /// results.
  ///
  /// Offline functionality is limited with `cloud_firestore` (which firefuel
  /// wraps) and had a couple of caveats.
  ///
  /// 1. All offline updates are stored in a queue in memory. This means any
  /// actions (reads/writes) taken by the user when offline will only be kept
  /// around as long as the app is running in the foreground or background. Once
  /// the app is killed, all unsynced data is lost.
  /// 2. You can only perform actions on collections and documents that have
  /// been previously cached in memory. For example, imagine you start your app
  /// without internet access, at this point, `cloud_firestore` hasn't been able
  /// to pull down any data, so your cached database is empty. You'll only be
  /// able to create new collections>documents and get/listen to those created
  /// while offline. The best use case for this functionality is when your user
  /// has intermittent internet access. That way the cache has all the values
  /// your user is expecting when they go to interact with the app. A second use
  /// case could be when you want to give your user a "preview" of the app
  /// before ever making real updates to your database. Just keep the following
  /// point in mind.
  /// 3. Offline queries are SLOOOW, local data does not get indexed and all
  /// actions taken while offline need to be replayed with each additional
  /// query, leading to seemingly exponential wait times for simple actions.
  static bool isOnline = true;

  /// Initializes Firefuel with instance of [FirebaseFirestore]
  ///
  /// This method must be called before any other method of Firefuel
  ///
  /// All collections will reference [firestore]
  ///
  /// ---
  ///
  /// [env] is optional and will be prepended to all collection names
  /// [isOnline] is optional and will default to `true`. This option
  /// allows for you to define the initial state of your app. Afterwards use
  /// `Firefuel.isOnline = true/false` to update the value.
  ///
  /// Useful for separating collections between app flavors / environments
  static void initialize(
    FirebaseFirestore firestore, {
    String? env,
    bool isOnline = true,
  }) {
    _firestore = firestore;
    _env = env;
    Firefuel.isOnline = isOnline;
  }
}
