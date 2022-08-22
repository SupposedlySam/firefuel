import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firefuel_counter/firefuel_counter.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';

import 'app.dart';
import 'counter_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize firefuel with fake firestore instance
  await Firebase.initializeApp();
  Firefuel.initialize(FirebaseFirestore.instance);

  Bloc.observer = CounterObserver();
  runApp(const CounterApp());
}
