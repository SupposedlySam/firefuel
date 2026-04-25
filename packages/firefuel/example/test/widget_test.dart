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
    expect(find.text('Live notes'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Create a document'), findsOneWidget);
  });

  testWidgets('create demo adds a note', (tester) async {
    await tester.pumpWidget(const FirefuelPlaygroundApp());
    await tester.pumpAndSettle();

    final createButton = find.byKey(
      const ValueKey('Create a document demo button'),
    );
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('server timestamp').hitTestable(),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('last result stays visible while scrolling', (tester) async {
    await tester.pumpWidget(const FirefuelPlaygroundApp());
    await tester.pumpAndSettle();

    final createButton = find.byKey(
      const ValueKey('Create a document demo button'),
    );
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('server timestamp').hitTestable(),
      findsAtLeastNWidgets(1),
    );
  });
}
