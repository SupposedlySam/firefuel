import 'package:flutter/material.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_counter/app.dart';
import 'package:flutter_counter/counter/counter.dart';

void main() {
  setUp(() => Firefuel.initialize(FakeFirebaseFirestore()));

  tearDown(Firefuel.reset);

  group('CounterApp', () {
    testWidgets('is a MaterialApp', (tester) async {
      expect(const CounterApp(), isA<MaterialApp>());
    });

    testWidgets('home is CounterPage', (tester) async {
      expect(const CounterApp().home, isA<CounterPage>());
    });

    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const CounterApp());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
