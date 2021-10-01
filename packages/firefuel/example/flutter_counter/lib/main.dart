import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firefuel/firefuel.dart';

import 'app.dart';
import 'counter_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firestoreInstance = FakeFirebaseFirestore();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Used to mock Firestore
  Firefuel.initialize(firestoreInstance);

  Bloc.observer = CounterObserver();
  runApp(const CounterApp());
}
