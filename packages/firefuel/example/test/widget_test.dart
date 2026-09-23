import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firefuel/firefuel.dart';
import 'package:flutter/material.dart';
import 'package:firefuel_example/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => Firefuel.initialize(FakeFirebaseFirestore()));

  tearDown(Firefuel.reset);

  testWidgets('playground renders feature cards and seeded data', (
    tester,
  ) async {
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

  testWidgets('every demo runs without an error', (tester) async {
    const titles = [
      'Seed sample data',
      'Create a document',
      'Read or create',
      'Update fields',
      'Array transforms',
      'Query and aggregate',
      'Paginate',
      'Multi-document reads',
      'OR queries and cursors',
      'One-shot aggregate',
      'Field updates',
      'Transaction',
      'Snapshot metadata',
      'Delete',
    ];

    await tester.pumpWidget(const FirefuelPlaygroundApp());
    await tester.pumpAndSettle();

    final ran = <String>[];
    for (final title in titles) {
      final button = find.byKey(ValueKey('$title demo button'));
      // Cards live on pages of a PageView; swipe until this one is on screen.
      for (var swipe = 0; swipe < 20; swipe++) {
        if (button.hitTestable().evaluate().isNotEmpty) break;
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
      }
      if (button.hitTestable().evaluate().isEmpty) {
        // Wrap around to the first page and search again.
        for (var swipe = 0; swipe < 20; swipe++) {
          await tester.drag(find.byType(PageView), const Offset(400, 0));
          await tester.pumpAndSettle();
          if (button.hitTestable().evaluate().isNotEmpty) break;
        }
      }

      await tester.tap(button.hitTestable());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Something went wrong'),
        findsNothing,
        reason: '"$title" reported an error',
      );
      ran.add(title);
    }

    // Positive control: every card was found and tapped.
    expect(ran, titles);
  });
}
