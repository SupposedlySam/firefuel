import 'package:flutter/material.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel_example/app.dart';
import 'package:firefuel_example/playground/playground.dart';

void main() {
  setUp(() => Firefuel.initialize(FakeFirebaseFirestore()));

  tearDown(Firefuel.reset);

  group('FirefuelPlaygroundApp', () {
    testWidgets('is a MaterialApp', (tester) async {
      expect(const FirefuelPlaygroundApp(), isA<MaterialApp>());
    });

    testWidgets('home is PlaygroundPage', (tester) async {
      expect(const FirefuelPlaygroundApp().home, isA<PlaygroundPage>());
    });

    testWidgets('renders PlaygroundPage', (tester) async {
      await tester.pumpWidget(const FirefuelPlaygroundApp());
      expect(find.byType(PlaygroundPage), findsOneWidget);
    });
  });
}
