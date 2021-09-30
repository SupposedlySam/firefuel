// ignore_for_file: prefer_const_constructors

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:flutter_counter/counter/counter.dart';
import 'package:flutter_counter/counter/view/counter_view.dart';

void main() {
  group('CounterPage', () {
    testWidgets('renders CounterView', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CounterPage()));
      expect(find.byType(CounterView), findsOneWidget);
    });
  });
}
