import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../utils/test_collection.dart';
import '../utils/test_user.dart';
import '../utils/test_backend.dart';

class OtherCollection extends TestCollection {
  OtherCollection({super.firestore});

  @override
  String get path => 'otherUsers';
}

void main() {
  late FirebaseFirestore firestore;
  late TestCollection users;
  late OtherCollection others;
  final fryId = DocumentId('fry');
  final leelaId = DocumentId('leela');
  const fry = TestUser('Fry', age: 25);
  const leela = TestUser('Leela', age: 27);

  setUp(() async {
    firestore = await testFirestore();
    Firefuel.initialize(firestore);
    users = TestCollection();
    others = OtherCollection();
  });

  tearDown(Firefuel.reset);

  group('Firefuel.runTransaction', () {
    test('should read typed values and write through converters', () async {
      await users.createById(value: fry, docId: fryId);

      final result = await Firefuel.runTransaction((transaction) async {
        final scope = transaction.of(users);
        final read = await scope.read(fryId);

        scope.update(
          docId: fryId,
          value: TestUser(read!.name, age: read.age! + 1),
        );
        return read.age;
      });

      expect(result, 25);
      expect((await users.read(fryId))!.age, 26);
    });

    test('should write to several collections atomically', () async {
      await Firefuel.runTransaction((transaction) async {
        transaction.of(users).createById(docId: fryId, value: fry);
        transaction.of(others).createById(docId: leelaId, value: leela);
      });

      expect(await users.read(fryId), fry);
      expect(await others.read(leelaId), leela);
    });

    // Rollback on a throwing handler is Firestore's guarantee, not
    // firefuel's, and fake_cloud_firestore applies transaction writes
    // immediately, so it is not asserted here.

    test('should refuse a read after a write', () async {
      await expectLater(
        Firefuel.runTransaction((transaction) async {
          final scope = transaction.of(users)
            ..createById(docId: fryId, value: fry);
          await scope.read(leelaId);
        }),
        throwsA(isA<ReadAfterWriteException>()),
      );
    });

    for (final (name, write) in [
      (
        'update',
        (TransactionScope<TestUser> scope, DocumentId id) =>
            scope.update(docId: id, value: fry),
      ),
      (
        'delete',
        (TransactionScope<TestUser> scope, DocumentId id) => scope.delete(id),
      ),
    ]) {
      test('should refuse a read after $name', () async {
        await users.createById(value: fry, docId: fryId);

        await expectLater(
          Firefuel.runTransaction((transaction) async {
            final scope = transaction.of(users);
            write(scope, fryId);
            await scope.read(leelaId);
          }),
          throwsA(isA<ReadAfterWriteException>()),
        );
      });
    }

    test('should run on an instance it is given', () async {
      final other = await otherTestFirestore();
      final elsewhere = TestCollection(firestore: other);

      await Firefuel.runTransaction(firestore: other, (transaction) async {
        transaction.of(elsewhere).createById(docId: fryId, value: fry);
      });

      expect(await elsewhere.read(fryId), fry);
      expect(await users.read(fryId), isNull);
    }, skip: skipWithoutOtherFirestore);

    test('readOrCreate should create only when missing', () async {
      final created = await Firefuel.runTransaction(
        (transaction) =>
            transaction.of(users).readOrCreate(docId: fryId, createValue: fry),
      );
      final existing = await Firefuel.runTransaction(
        (transaction) => transaction
            .of(users)
            .readOrCreate(docId: fryId, createValue: leela),
      );

      expect(created, fry);
      expect(existing, fry);
      expect(await users.read(fryId), fry);
    });

    test('should refuse a collection on another instance', () async {
      final elsewhere = TestCollection(firestore: await otherTestFirestore());

      await expectLater(
        Firefuel.runTransaction((transaction) async {
          transaction.of(elsewhere);
        }),
        throwsA(isA<MixedFirestoreInstancesException>()),
      );
    }, skip: skipWithoutOtherFirestore);
  });

  group('Firefuel.batch', () {
    test('should write nothing until commit, then everything', () async {
      final batch = Firefuel.batch();
      batch.of(users).createById(docId: fryId, value: fry);
      final leelaDoc = batch.of(others).create(leela);

      expect(await users.read(fryId), isNull);

      await batch.commit();

      expect(await users.read(fryId), fry);
      expect(await others.read(leelaDoc), leela);
    });

    test('should apply updateFields with FieldUpdate values', () async {
      await users.createById(value: fry, docId: fryId);

      final batch = Firefuel.batch();
      batch
          .of(users)
          .updateFields(
            docId: fryId,
            fields: {TestUser.fieldAge: const FieldUpdate.increment(10)},
          );
      await batch.commit();

      expect((await users.read(fryId))!.age, 35);
    });

    test('replace should see a create queued earlier in the batch', () async {
      final batch = Firefuel.batch();
      batch.of(users)
        ..createById(docId: fryId, value: fry)
        ..replace(docId: fryId, value: leela);
      await batch.commit();

      expect(await users.read(fryId), leela);
    });

    test('should write to an instance it is given', () async {
      final other = await otherTestFirestore();
      final elsewhere = TestCollection(firestore: other);

      final batch = Firefuel.batch(firestore: other);
      batch.of(elsewhere).createById(docId: fryId, value: fry);
      await batch.commit();

      expect(await elsewhere.read(fryId), fry);
      expect(await users.read(fryId), isNull);
    }, skip: skipWithoutOtherFirestore);

    test('should delete', () async {
      await users.createById(value: fry, docId: fryId);

      final batch = Firefuel.batch();
      batch.of(users).delete(fryId);
      await batch.commit();

      expect(await users.read(fryId), isNull);
    });

    test('should refuse a collection on another instance', () async {
      final elsewhere = TestCollection(firestore: await otherTestFirestore());

      expect(
        () => Firefuel.batch().of(elsewhere),
        throwsA(isA<MixedFirestoreInstancesException>()),
      );
    }, skip: skipWithoutOtherFirestore);
  });
}
