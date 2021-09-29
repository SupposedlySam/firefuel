import 'package:bloc/bloc.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'counter_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // await Firebase.initializeApp();

  // Used to mock Firestore
  final firestoreInstance = FakeFirebaseFirestore();
  Firefuel.initialize(firestoreInstance);

  Bloc.observer = CounterObserver();
  runApp(const CounterApp());
}
