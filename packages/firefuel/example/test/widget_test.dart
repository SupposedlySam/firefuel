import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter/material.dart';
import 'package:firefuel_example/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => Firefuel.initialize(FakeFirebaseFirestore()));

  tearDown(Firefuel.reset);

  testWidgets('playground renders feature cards and seeded data',
      (tester) async {
    await tester.pumpWidget(const FirefuelPlaygroundApp());
    await tester.pumpAndSettle();

    expect(find.text('Firefuel Playground'), findsOneWidget);
    expect(find.text('Create a document'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Query and aggregate'),
      250,
    );
    expect(find.text('Query and aggregate'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Welcome note'),
      250,
    );
    expect(find.text('Welcome note'), findsOneWidget);
  });

  testWidgets('create demo adds a note', (tester) async {
    await tester.pumpWidget(const FirefuelPlaygroundApp());
    await tester.pumpAndSettle();

    final createButton = find.byKey(
      const ValueKey('Create a document demo button'),
    );
    await tester.scrollUntilVisible(createButton, 250);
    await tester.ensureVisible(createButton);
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Created note 1'), 250);
    expect(find.text('Created note 1'), findsOneWidget);
  });
}
