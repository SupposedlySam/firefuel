import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import '../utils/test_collection.dart';
import '../utils/test_user.dart';

void main() {
  late TestCollection testCollection;
  const defaultUser = TestUser('testName');

  setUp(() {
    Firefuel.initialize(FakeFirebaseFirestore());
    testCollection = TestCollection();
  });

  tearDown(Firefuel.reset);

  group('#countAll', () {
    setUp(() async {
      await testCollection.create(defaultUser);
      await testCollection.create(defaultUser);
      await testCollection.create(defaultUser);
    });

    test('should return the amount of documents in the collection', () async {
      final actual = await testCollection.countAll();

      expect(actual, 3);
    });
  });

  group('#countWhere', () {
    setUp(() async {
      await testCollection.create(defaultUser);
      await testCollection.create(defaultUser);
      await testCollection.create(defaultUser);
    });

    test(
      'should return the amount of documents in the collection, filtered by '
      'the provided clauses',
      () async {
        const newUserName = 'newUser';
        await testCollection.create(const TestUser(newUserName));

        final actual = await testCollection.countWhere([
          Clause(TestUser.fieldName, isEqualTo: newUserName),
        ]);

        expect(actual, 1);
      },
    );
  });

  group('#create', () {
    test('should return a new document', () async {
      final originalDocId = await testCollection.create(defaultUser);
      final secondDocId = await testCollection.create(defaultUser);

      expect(originalDocId, isNot(secondDocId));
    });

    test('should create a new document with the values provided', () async {
      const newUser = TestUser('overwrittenUser');
      final createdDocId = await testCollection.create(newUser);

      final updatedUser = await testCollection.read(createdDocId);

      expect(updatedUser, newUser);
    });
  });

  group('#createById', () {
    final originalDocId = DocumentId('originalDocId');

    test('should create the document with provided id', () async {
      await testCollection.createById(
        value: defaultUser,
        docId: originalDocId,
      );

      final readResult = await testCollection.read(originalDocId);

      expect(defaultUser, readResult);
    });

    test('should overwrite the document with the values provided', () async {
      const newUser = TestUser('newUser');
      final createdDocId = await testCollection.create(newUser);

      const updatedUser = TestUser('updatedUser');
      await testCollection.createById(
        value: updatedUser,
        docId: createdDocId,
      );

      final overwrittenUser = await testCollection.read(createdDocId);

      expect(updatedUser, overwrittenUser);
    });
  });

  group('#delete', () {
    late DocumentId defaultDocId;

    setUp(() async {
      defaultDocId = await testCollection.create(defaultUser);
    });

    test('should remove the document', () async {
      await testCollection.delete(defaultDocId);

      final readResult = await testCollection.read(defaultDocId);

      expect(readResult, isNull);
    });
  });

  group('#generateDocId', () {
    test('should create a new id with each call', () {
      final docId1 = testCollection.generateDocId();
      final docId2 = testCollection.generateDocId();

      expect(docId1, isNot(docId2));
    });
  });

  group('#limit', () {
    setUp(() async {
      await testCollection.create(defaultUser);
      await testCollection.create(defaultUser);
      await testCollection.create(defaultUser);
    });

    test('when items are less than limit, should return all items', () async {
      final result = await testCollection.limit(4);

      expect(
        result,
        [defaultUser, defaultUser, defaultUser],
      );
    });

    test(
      'when items are greater than limit, should return items up to limit',
      () async {
        final result = await testCollection.limit(2);

        expect(
          result,
          [defaultUser, defaultUser],
        );
      },
    );

    test(
      'when items are equal to limit, should return all items',
      () async {
        final result = await testCollection.limit(3);

        expect(
          result,
          [defaultUser, defaultUser, defaultUser],
        );
      },
    );
  });

  group('#stream', () {
    late Stream<TestUser?> stream;
    late DocumentId docId;

    setUp(() async {
      docId = await testCollection.create(defaultUser);

      stream = testCollection.stream(docId);
    });

    test('should output new value when doc updates', () async {
      const newUser1 = TestUser('newUser1');
      const newUser2 = TestUser('newUser2');
      const newUser3 = TestUser('newUser3');

      expect(stream, emitsInOrder([defaultUser, newUser1, newUser2, newUser3]));

      await testCollection.update(docId: docId, value: newUser1);
      await testCollection.update(docId: docId, value: newUser2);
      await testCollection.update(docId: docId, value: newUser3);
    });

    test('should output null when doc no longer exists', () async {
      const newUser = TestUser('newUser');

      expect(stream, emitsInOrder([defaultUser, newUser, null]));

      await testCollection.update(docId: docId, value: newUser);
      await testCollection.delete(docId);
    });
  });

  group('#streamAll', () {
    late Stream<List<TestUser>> stream;
    late DocumentId docId;
    const newUser1 = TestUser('newUser1');
    const newUser2 = TestUser('newUser2');

    setUp(() async {
      docId = await testCollection.create(defaultUser);
      await testCollection.create(newUser1);

      stream = testCollection.streamAll();
    });

    test('should update when an item is added', () async {
      expect(
        stream,
        emitsInOrder([
          [defaultUser, newUser1],
          [defaultUser, newUser1, newUser2],
        ]),
      );

      await testCollection.create(newUser2);
    });

    test('should update when an item is deleted', () async {
      expect(
        stream,
        emitsInOrder([
          [defaultUser, newUser1],
          [newUser1],
        ]),
      );

      await testCollection.delete(docId);
    });
  });

  group('#streamCountAll', () {
    late Stream<int> stream;
    late DocumentId docId;

    setUp(() async {
      docId = await testCollection.create(defaultUser);

      stream = testCollection.streamCountAll();
    });

    test('should output new value when new doc is created', () async {
      expect(stream, emitsInOrder([1, 2]));

      await testCollection.create(defaultUser);
    });

    test('should output 0 when docs no longer exists', () async {
      expect(stream, emitsInOrder([1, 0]));

      await testCollection.delete(docId);
    });
  });

  group('#streamLimited', () {
    setUp(() async {
      await testCollection.create(defaultUser);
      await testCollection.create(defaultUser);
      await testCollection.create(defaultUser);
    });

    test('when items are less than limit, should return all items', () {
      final stream = testCollection.streamLimited(4);

      expect(
        stream,
        emitsInOrder([
          [defaultUser, defaultUser, defaultUser],
        ]),
      );
    });

    test(
      'when items are greater than limit, should return items up to limit',
      () {
        final stream = testCollection.streamLimited(2);

        expect(
          stream,
          emitsInOrder([
            [defaultUser, defaultUser],
          ]),
        );
      },
    );

    test(
      'when items are equal to limit, should return all items',
      () {
        final stream = testCollection.streamLimited(3);

        expect(
          stream,
          emitsInOrder([
            [defaultUser, defaultUser, defaultUser],
          ]),
        );
      },
    );
  });

  group('#streamOrdered', () {
    late Stream<List<TestUser>> stream;
    late DocumentId docId;
    const newUser1 = TestUser('Alfred');
    const newUser2 = TestUser('Batman');
    const newUser3 = TestUser('Catwoman');

    setUp(() async {
      docId = await testCollection.create(newUser1);
      await testCollection.create(newUser3);

      stream =
          testCollection.streamOrdered([OrderBy(field: TestUser.fieldName)]);
    });

    test('should return an ordered list', () async {
      await testCollection.create(newUser2);

      expect(
        stream,
        emitsInOrder([
          [newUser1, newUser2, newUser3],
        ]),
      );
    });

    test('should update when an item is added', () async {
      expect(
        stream,
        emitsInOrder([
          [newUser1, newUser3],
          [newUser1, newUser2, newUser3],
        ]),
      );

      await testCollection.create(newUser2);
    });

    test('should update when an item is deleted', () async {
      expect(
        stream,
        emitsInOrder([
          [newUser1, newUser3],
          [newUser3],
        ]),
      );

      await testCollection.delete(docId);
    });
  });

  group('#streamCountWhere', () {
    late Stream<int> stream;
    late DocumentId docId;

    setUp(() async {
      docId = await testCollection.create(defaultUser);

      stream = testCollection.streamCountWhere([
        Clause(TestUser.fieldName, isEqualTo: defaultUser.name),
      ]);
    });

    test(
      'should output new value when new doc is created matching the clause',
      () async {
        expect(stream, emitsInOrder([1, 2]));

        await testCollection.create(const TestUser('newUser1')); // no emit
        await testCollection.create(const TestUser('newUser1')); // no emit
        await testCollection.create(defaultUser); // emit
      },
    );

    test('should output 0 when matching docs no longer exists', () async {
      const nonVisibleUser = TestUser('newUser1');

      expect(stream, emitsInOrder([1, 0]));

      // If this was visible it would emit 2
      final docIdToDelete = await testCollection.create(nonVisibleUser);
      // If this was visible it would emit 1
      await testCollection.delete(docIdToDelete);
      // If this was visible it would emit 2 again
      await testCollection.create(nonVisibleUser);
      // Should actually emit 0
      await testCollection.delete(docId); // emit
    });
  });

  group('#streamWhere', () {
    const expectedName = 'expectedName';
    const expectedUser = TestUser(expectedName);

    group('with clause', () {
      const unexpectedName1 = 'unexpectedName1';
      const unexpectedName2 = 'unexpectedName2';

      setUp(() async {
        await testCollection.create(const TestUser(unexpectedName1));
        await testCollection.create(expectedUser);
        await testCollection.create(const TestUser(unexpectedName2));
      });

      test('should return a subset of the existing list', () {
        final filteredStream = testCollection.streamWhere(
          [Clause(TestUser.fieldName, isEqualTo: expectedName)],
        );

        expect(
          filteredStream,
          emitsInOrder([
            [expectedUser],
          ]),
        );
      });

      test('should return a subset based on multiple clauses', () {
        final filteredStream = testCollection.streamWhere(
          [
            Clause(TestUser.fieldName, isNotEqualTo: unexpectedName1),
            Clause(TestUser.fieldName, isNotEqualTo: unexpectedName2),
          ],
        );

        expect(
          filteredStream,
          emitsInOrder([
            [expectedUser],
          ]),
        );
      });

      test('should throw $MissingValueException when no clauses are given', () {
        expect(
          () => testCollection.streamWhere([]),
          throwsA(isA<MissingValueException>()),
        );
      });

      test(
        'should throw $MoreThanOneFieldInRangeClauseException when more than '
        'one field is used in multiple range clauses',
        () {
          expect(
            () => testCollection.streamWhere([
              Clause('firstField', isGreaterThan: 44),
              Clause('secondField', isLessThan: 22),
            ]),
            throwsA(isA<MoreThanOneFieldInRangeClauseException>()),
          );
        },
      );
    });

    group('with orderBy should return a subset of the existing list', () {
      const leela = TestUser('Leela', age: 25, occupation: 'Pilot');
      const bender = TestUser('Bender', age: 4, occupation: 'Soldier');
      const fry = TestUser('Fry', age: 25, occupation: 'Delivery Boy');

      setUp(() async {
        await testCollection.create(leela);
        await testCollection.create(bender);
        await testCollection.create(fry);
      });

      test('when first $OrderBy matches first $Clause', () {
        final filteredList = testCollection.streamWhere(
          [Clause(TestUser.fieldName, isNotEqualTo: expectedUser)],
          orderBy: [OrderBy(field: TestUser.fieldName)],
        );

        expect(
          filteredList,
          emitsInOrder([
            [bender, fry, leela],
          ]),
        );
      });

      group(
        'when using a range comparison',
        () {
          const oldFry = TestUser('Fry', age: 1025, occupation: 'Delivery Boy');

          setUp(() async {
            await testCollection.create(oldFry);
          });

          test('and $OrderBy does not exist for first $Clause', () {
            expect(
              testCollection.streamWhere(
                [Clause(TestUser.fieldAge, isGreaterThan: 4)],
                orderBy: [OrderBy(field: TestUser.fieldName)],
                limit: 1,
              ),
              emitsInOrder([
                [fry],
              ]),
            );
          });

          test('and matching $OrderBy is not first in orderBy list', () {
            expect(
              testCollection.streamWhere(
                [Clause(TestUser.fieldAge, isGreaterThan: 4)],
                orderBy: [
                  OrderBy(field: TestUser.fieldName),
                  OrderBy(field: TestUser.fieldAge),
                ],
              ),
              emitsInOrder([
                [fry, oldFry, leela],
              ]),
            );
          });
        },
        skip: true,
      ); // Skipping due to a regression with the fake_cloud_firestore
      // version causing ordering to fail

      group('when using a equality comparison', () {
        test('and has matching $OrderBy field', () {
          expect(
            testCollection.streamWhere(
              [Clause(TestUser.fieldAge, isEqualTo: 25)],
              orderBy: [OrderBy(field: TestUser.fieldAge)],
            ),
            emitsInOrder([
              [leela, fry],
            ]),
          );
        });

        test('and has matching $OrderBy field', () {
          expect(
            testCollection.streamWhere(
              [Clause(TestUser.fieldAge, isNull: true)],
              orderBy: [OrderBy(field: TestUser.fieldAge)],
            ),
            emitsInOrder([
              <String>[],
            ]),
          );
        });
      });

      group('when using a in comparison', () {
        test('and has matching $OrderBy field', () {
          expect(
            testCollection.streamWhere(
              [
                Clause(TestUser.fieldAge, whereIn: const [4, 25]),
              ],
              orderBy: [OrderBy(field: TestUser.fieldAge)],
            ),
            emitsInOrder([
              [leela, bender, fry],
            ]),
          );
        });
      });
    });

    group('with limit', () {
      test('should set the max value of items to return', () async {
        await testCollection.create(expectedUser);
        await testCollection.create(expectedUser);

        final limitedStream = testCollection.streamWhere(
          [Clause(TestUser.fieldName, isEqualTo: expectedName)],
          limit: 1,
        );

        expect(
          limitedStream,
          emitsInOrder([
            [expectedUser],
          ]),
        );
      });
    });
  });

  group('#orderBy', () {
    const testUsername1 = 'Alfred';
    const testUsername2 = 'Batman';
    const testUsername3 = 'Catwoman';
    const testUser1 = TestUser(testUsername1);
    const testUser2 = TestUser(testUsername2);
    const testUser3 = TestUser(testUsername3);

    setUp(() async {
      await testCollection.create(testUser1);
      await testCollection.create(testUser2);
      await testCollection.create(testUser3);
    });

    test('should throw when no orderBys are given', () async {
      expect(
        () async => testCollection.orderBy([]),
        throwsA(isA<MissingValueException>()),
      );
    });

    test('should return results in ascending order', () async {
      final usersResult = await testCollection.orderBy(
        [OrderBy(field: TestUser.fieldName, direction: OrderDirection.aToZ)],
      );

      expect(usersResult, [testUser1, testUser2, testUser3]);
    });

    test('should return results in descending order', () async {
      final usersResult = await testCollection.orderBy(
        [OrderBy(field: TestUser.fieldName, direction: OrderDirection.zToA)],
      );

      expect(usersResult, [testUser3, testUser2, testUser1]);
    });
  });

  group('#paginate', () {
    setUp(() async {
      final scenarioCount = ChunkStatus.values.length;
      final seedCount = Chunk.defaultLimit * scenarioCount - 1;

      await Future.wait(
        List.generate(
          seedCount,
          (i) => testCollection.create(TestUser('User$i')),
        ),
      );
    });

    test('should use the Chunk.defaultLimit', () async {
      final startingChunk = await testCollection.paginate(
        Chunk(orderBy: [OrderBy(field: TestUser.fieldName)]),
      );

      expect(startingChunk.data.length, Chunk.defaultLimit);
    });

    test(
      'should have status of $ChunkStatus.nextAvailable when receiving the '
      'middle chunk',
      () async {
        final middleChunk = await testCollection.paginate(
          Chunk(orderBy: [OrderBy(field: TestUser.fieldName)]),
        );

        expect(middleChunk.status, ChunkStatus.nextAvailable);
      },
    );

    test(
      'should have status of $ChunkStatus.last when receiving the last chunk',
      () async {
        final middleChunk = await testCollection.paginate(
          Chunk(orderBy: [OrderBy(field: TestUser.fieldName)]),
        );
        final lastChunk = await testCollection.paginate(middleChunk);

        expect(lastChunk.status, ChunkStatus.last);
      },
    );

    test(
      'should return empty data when the last chunk is passed back in',
      () async {
        final middleChunk = await testCollection.paginate(
          Chunk(orderBy: [OrderBy(field: TestUser.fieldName)]),
        );
        final lastChunk = await testCollection.paginate(middleChunk);

        assert(lastChunk.status == ChunkStatus.last, 'should be last');

        final emptyLastChunk2 = await testCollection.paginate(lastChunk);

        expect(emptyLastChunk2.status, ChunkStatus.last);
        expect(emptyLastChunk2.data.isEmpty, isTrue);
        expect(emptyLastChunk2.cursor, isNull);
      },
    );

    test(
      'should return empty data when last chunk contains nothing',
      () async {
        // We're starting with minus document to make a full chunk so adding one
        // more user will allow two full chunks
        await testCollection.create(const TestUser('LastUser'));

        final middleChunk = await testCollection.paginate(
          Chunk(orderBy: [OrderBy(field: TestUser.fieldName)]),
        );
        final lastFullChunk = await testCollection.paginate(middleChunk);

        final emptyLastChunk = await testCollection.paginate(lastFullChunk);

        expect(emptyLastChunk.status, ChunkStatus.last);
        expect(emptyLastChunk.data.isEmpty, isTrue);
        expect(emptyLastChunk.cursor, isNull);
      },
    );
  });

  group('#read', () {
    test('should return the Type when docId exists', () async {
      final docId = await testCollection.create(defaultUser);

      final readResult = await testCollection.read(docId);

      expect(readResult, defaultUser);
    });

    test('should return null when docId does not exist', () async {
      final readResult = await testCollection.read(DocumentId('dodoBird'));

      expect(readResult, isNull);
    });
  });

  group('#readAll', () {
    const expectedUser1 = TestUser('expectedUser');
    const expectedUser2 = TestUser('expectedUser');
    const expectedUser3 = TestUser('expectedUser');
    final userList = [expectedUser1, expectedUser2, expectedUser3];

    test('should return all items', () async {
      await testCollection.create(expectedUser1);
      await testCollection.create(expectedUser2);
      await testCollection.create(expectedUser3);

      final readResult = await testCollection.readAll();

      expect(readResult, userList);
    });

    test('should return emtpy list when no items in collection', () async {
      final readResult = await testCollection.readAll();

      expect(readResult, <String>[]);
    });
  });

  group('#readOrCreate', () {
    final documentId = DocumentId('testName');

    test('should create the doc when it does not exist', () async {
      final result = await testCollection.readOrCreate(
        docId: documentId,
        createValue: defaultUser,
      );

      expect(result, defaultUser);
    });

    test('should get doc when it exists', () async {
      final docId = await testCollection.create(defaultUser);

      final testUser = await testCollection.readOrCreate(
        docId: docId,
        createValue: defaultUser,
      );

      expect(docId.docId, testUser.docId);
    });
  });

  group('#replace', () {
    final originalDocId = DocumentId('originalDocId');

    test('should fail silently when document does not exist', () async {
      final nonExistentDoc = DocumentId('dodoBird');
      const newValue = TestUser('Clark Kent');

      final nonExistentDocReadBeforeReplace = await testCollection.read(
        nonExistentDoc,
      );

      expect(nonExistentDocReadBeforeReplace, isNull);

      await testCollection.replace(
        docId: nonExistentDoc,
        value: newValue,
      );

      final nonExistentDocReadAfterReplace = await testCollection.read(
        nonExistentDoc,
      );

      expect(nonExistentDocReadAfterReplace, isNull);
    });

    test('should overwrite all values in document', () async {
      const newUser = TestUser('newUser');
      const updatedUser = TestUser('updatedUser');

      await testCollection.createById(value: newUser, docId: originalDocId);

      await testCollection.replace(
        value: updatedUser,
        docId: originalDocId,
      );

      final readUser = await testCollection.read(originalDocId);

      expect(updatedUser, readUser);
    });
  });

  group('#replaceFields', () {
    late DocumentId docId;
    const replacementName = 'someNewValue';
    const replacement = TestUser(replacementName);

    setUp(() async {
      docId = await testCollection.create(defaultUser);
    });

    test('should replace fields in the list', () async {
      await testCollection.replaceFields(
        docId: docId,
        value: replacement,
        fieldPaths: [TestUser.fieldName],
      );

      final updatedUser = await testCollection.read(docId);

      expect(updatedUser!.name, replacementName);
    });

    test('should not replace fields missing from the list', () async {
      const replacementName = 'someNewValue';
      const replacement = TestUser(replacementName);

      await testCollection.replaceFields(
        docId: docId,
        value: replacement,
        fieldPaths: ['fakeField'],
      );

      final unchangedUser = await testCollection.read(docId);

      expect(unchangedUser!.name, isNot(replacementName));
    });
  });

  group('#update', () {
    test('should overwrite existing fields', () async {
      const updatedDoc = TestUser('updateValue');
      final docId = await testCollection.create(defaultUser);

      await testCollection.update(
        docId: docId,
        value: updatedDoc,
      );

      final readResult = await testCollection.read(docId);

      expect(readResult, updatedDoc);
    });
  });

  group('#updateOrCreate', () {
    test('should create new document when document does not exist', () async {
      final originalDocId = DocumentId('originalDocId');
      const newUser = TestUser('newUser');

      await testCollection.updateOrCreate(
        docId: originalDocId,
        value: newUser,
      );

      final updatedDoc = await testCollection.read(originalDocId);

      expect(updatedDoc, newUser);
    });

    test('should overwrite existing fields', () async {
      const updatedDoc = TestUser('updateValue');
      final docId = await testCollection.create(defaultUser);

      await testCollection.updateOrCreate(
        docId: docId,
        value: updatedDoc,
      );

      final readResult = await testCollection.read(docId);

      expect(readResult, updatedDoc);
    });
  });

  group('#where', () {
    const expectedName = 'expectedName';
    const expectedUser = TestUser(expectedName);
    const unexpectedName1 = 'unexpectedName1';
    const unexpectedName2 = 'unexpectedName2';

    group('with clauses', () {
      setUp(() async {
        await testCollection.create(const TestUser(unexpectedName1));
        await testCollection.create(expectedUser);
        await testCollection.create(const TestUser(unexpectedName2));
      });

      test('should return a subset of the existing list', () async {
        final filteredList = await testCollection.where(
          [Clause(TestUser.fieldName, isEqualTo: expectedName)],
        );

        expect(filteredList, [expectedUser]);
      });

      test('should return a subset based on multiple clauses', () async {
        final filteredList = await testCollection.where(
          [
            Clause(TestUser.fieldName, isNotEqualTo: unexpectedName1),
            Clause(TestUser.fieldName, isNotEqualTo: unexpectedName2),
          ],
        );

        expect(filteredList, [expectedUser]);
      });

      test(
        'should throw a $TooManyArgumentsException when more than one option '
        'is chosen',
        () {
          expect(
            () async => testCollection.where(
              [
                Clause(
                  TestUser.fieldName,
                  isNotEqualTo: unexpectedName1,
                  isEqualTo: expectedUser,
                ),
              ],
            ),
            throwsA(isA<TooManyArgumentsException>()),
          );
        },
      );

      test('should throw when no clauses are given', () async {
        expect(
          () async => testCollection.where([]),
          throwsA(isA<MissingValueException>()),
        );
      });

      test(
        'should throw $MoreThanOneFieldInRangeClauseException when more than '
        'one field is used in multiple range clauses',
        () {
          expect(
            () => testCollection.streamWhere([
              Clause('firstField', isGreaterThan: 44),
              Clause('secondField', isLessThan: 22),
            ]),
            throwsA(isA<MoreThanOneFieldInRangeClauseException>()),
          );
        },
      );
    });

    group('with orderBy should return a subset of the existing list', () {
      const leela = TestUser('Leela', age: 25, occupation: 'Pilot');
      const bender = TestUser('Bender', age: 4, occupation: 'Soldier');
      const fry = TestUser('Fry', age: 25, occupation: 'Delivery Boy');

      setUp(() async {
        await testCollection.create(leela);
        await testCollection.create(bender);
        await testCollection.create(fry);
      });

      test('when first $OrderBy matches first $Clause', () async {
        final filteredList = await testCollection.where(
          [Clause(TestUser.fieldName, isNotEqualTo: expectedUser)],
          orderBy: [OrderBy(field: TestUser.fieldName)],
        );

        expect(filteredList, [bender, fry, leela]);
      });

      group('when using a range comparison', () {
        const oldFry = TestUser('Fry', age: 1025, occupation: 'Delivery Boy');

        setUp(() async {
          await testCollection.create(oldFry);
        });

        test('and $OrderBy does not exist for first $Clause', () async {
          await expectLater(
            testCollection.where(
              [Clause(TestUser.fieldAge, isGreaterThan: 4)],
              orderBy: [OrderBy(field: TestUser.fieldName)],
            ),
            completes,
          );
        });

        test('and matching $OrderBy is not first in orderBy list', () async {
          await expectLater(
            testCollection.where(
              [Clause(TestUser.fieldAge, isGreaterThan: 4)],
              orderBy: [
                OrderBy(field: TestUser.fieldName),
                OrderBy(field: TestUser.fieldAge),
              ],
            ),
            completes,
          );
        });
      });

      group('when using a equality comparison', () {
        test('and has matching $OrderBy field', () async {
          await expectLater(
            testCollection.where(
              [Clause(TestUser.fieldAge, isEqualTo: 25)],
              orderBy: [OrderBy(field: TestUser.fieldAge)],
            ),
            completes,
          );
        });

        test('and has matching $OrderBy field', () async {
          await expectLater(
            testCollection.where(
              [Clause(TestUser.fieldAge, isNull: true)],
              orderBy: [OrderBy(field: TestUser.fieldAge)],
            ),
            completes,
          );
        });
      });

      group('when using a in comparison', () {
        test('and has matching $OrderBy field', () async {
          await expectLater(
            testCollection.where(
              [
                Clause(TestUser.fieldAge, whereIn: const [4, 25]),
              ],
              orderBy: [OrderBy(field: TestUser.fieldAge)],
            ),
            completes,
          );
        });
      });
    });

    group('with limit', () {
      test('should set the max value of items to return', () async {
        await testCollection.create(expectedUser);
        await testCollection.create(expectedUser);

        final filteredList = await testCollection.where(
          [Clause(TestUser.fieldName, isEqualTo: expectedName)],
          limit: 1,
        );

        expect(filteredList, [expectedUser]);
      });
    });
  });

  group('#whereById', () {
    test('should return the Type when docId exists', () async {
      final docId = await testCollection.create(defaultUser);

      final readResult = await testCollection.whereById(docId);

      expect(readResult, defaultUser);
    });

    test('should return null when docId does not exist', () async {
      final readResult = await testCollection.whereById(DocumentId('dodoBird'));

      expect(readResult, isNull);
    });
  });
}
