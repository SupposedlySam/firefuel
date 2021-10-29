import 'package:flutter/material.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_counter/counter/counter.dart';
import 'package:flutter_counter/counter/view/counter_view.dart';

void main() {
  setUp(() => Firefuel.initialize(FakeFirebaseFirestore()));

  group('CounterPage', () {
    testWidgets('renders CounterView', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CounterPage()));
      await tester.pump(); // enter FutureBuilder's builder function

      expect(find.byType(CounterView), findsOneWidget);
    });
  });
}
