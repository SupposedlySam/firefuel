import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firefuel/firefuel.dart';

import 'package:firefuel_example/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize firefuel with fake firestore instance
  Firefuel.initialize(FakeFirebaseFirestore());

  runApp(const FirefuelPlaygroundApp());
}
