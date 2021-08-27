import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/mock_firebase.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setupFirebaseMocks();
  await Firebase.initializeApp();

  await testMain();
}
