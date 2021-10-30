import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:firefuel/firefuel.dart';

import 'app.dart';
import 'counter_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize firefuel with fake firestore instance
  Firefuel.initialize(FakeFirebaseFirestore());

  Bloc.observer = CounterObserver();
  runApp(const CounterApp());
}
