import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firefuel/firefuel.dart';
import '../mocks/mock_collection.dart';
import '../utils/test_repository.dart';
import '../utils/test_user.dart';

/// Every repository method must hand its arguments to the collection
/// unchanged.
///
/// The Right/Left tests in firefuel_repository_test.dart stub with `any()`,
/// so they stay green when a repository drops an argument. That happened
/// once already: 0.4.5 fixed where/streamWhere silently discarding orderBy.
/// These tests stub nothing but the exact arguments; an argument that goes
/// missing makes the stub miss and the call return a Left.
void main() {
  late MockCollection<TestUser> collection;
  late TestRepository<TestUser> repository;

  final docId = DocumentId('forwarded');
  final docIds = [DocumentId('a'), DocumentId('b')];
  const user = TestUser('forwarded');
  const getOptions = GetOptions(source: Source.cache);
  const source = AggregateSource.server;
  final clauses = [Clause(TestUser.fieldName, isEqualTo: 'x')];
  final orderBy = [OrderBy(field: TestUser.fieldAge)];
  const field = TestUser.fieldAge;
  const fieldPaths = [TestUser.fieldName];
  const values = <Object?>['v'];
  const fields = <String, Object?>{TestUser.fieldName: 'y'};
  final chunk = Chunk<TestUser>(orderBy: orderBy, limit: 3);

  setUp(() {
    collection = MockCollection<TestUser>();
    repository = TestRepository(collection: collection);
  });

  /// Stubs [call] on the mock, runs [act] and expects a Right carrying
  /// [value]. A Left here means the repository forwarded different
  /// arguments than the stub expects.
  Future<void> expectForwarded<R>(
    Future<R> Function() call,
    R value,
    Future<Either<Failure, R>> Function() act,
  ) async {
    when(call).thenAnswer((_) async => value);

    final result = await act();

    expect(result.getLeftOrElseNull(), isNull, reason: 'stub was missed');
    expect(result.getRightOrElseNull(), value);
  }

  test('countAll', () async {
    await expectForwarded(
      () => collection.countAll(source: source),
      7,
      () => repository.countAll(source: source),
    );
  });

  test('countWhere', () async {
    await expectForwarded(
      () => collection.countWhere(clauses, source: source),
      7,
      () => repository.countWhere(clauses, source: source),
    );
  });

  test('sumAll', () async {
    await expectForwarded<double?>(
      () => collection.sumAll(field, source: source),
      3,
      () => repository.sumAll(field, source: source),
    );
  });

  test('sumWhere', () async {
    await expectForwarded<double?>(
      () => collection.sumWhere(clauses, field, source: source),
      3,
      () => repository.sumWhere(clauses, field, source: source),
    );
  });

  test('averageAll', () async {
    await expectForwarded<double?>(
      () => collection.averageAll(field, source: source),
      1.5,
      () => repository.averageAll(field, source: source),
    );
  });

  test('averageWhere', () async {
    await expectForwarded<double?>(
      () => collection.averageWhere(clauses, field, source: source),
      1.5,
      () => repository.averageWhere(clauses, field, source: source),
    );
  });

  test('createById', () async {
    await expectForwarded(
      () => collection.createById(value: user, docId: docId),
      docId,
      () => repository.createById(value: user, docId: docId),
    );
  });

  test('limit', () async {
    await expectForwarded(() => collection.limit(2, getOptions: getOptions), [
      user,
    ], () => repository.limit(2, getOptions: getOptions));
  });

  test('orderBy', () async {
    await expectForwarded(
      () => collection.orderBy(orderBy, limit: 2, getOptions: getOptions),
      [user],
      () => repository.orderBy(orderBy, limit: 2, getOptions: getOptions),
    );
  });

  test('paginate', () async {
    await expectForwarded(
      () => collection.paginate(chunk, getOptions: getOptions),
      chunk,
      () => repository.paginate(chunk, getOptions: getOptions),
    );
  });

  test('read', () async {
    await expectForwarded<TestUser?>(
      () => collection.read(docId, getOptions: getOptions),
      user,
      () => repository.read(docId, getOptions: getOptions),
    );
  });

  test('readMany', () async {
    await expectForwarded<List<TestUser?>>(
      () => collection.readMany(docIds, getOptions: getOptions),
      [user, null],
      () => repository.readMany(docIds, getOptions: getOptions),
    );
  });

  test('readAll', () async {
    await expectForwarded(() => collection.readAll(getOptions: getOptions), [
      user,
    ], () => repository.readAll(getOptions: getOptions));
  });

  test('readOrCreate', () async {
    await expectForwarded(
      () => collection.readOrCreate(
        docId: docId,
        createValue: user,
        getOptions: getOptions,
      ),
      user,
      () => repository.readOrCreate(
        docId: docId,
        createValue: user,
        getOptions: getOptions,
      ),
    );
  });

  test('replaceFields', () async {
    when(
      () => collection.replaceFields(
        docId: docId,
        value: user,
        fieldPaths: fieldPaths,
      ),
    ).thenAnswer((_) async {});

    final result = await repository.replaceFields(
      docId: docId,
      value: user,
      fieldPaths: fieldPaths,
    );

    expect(result.isRight(), isTrue);
  });

  test('updateFields', () async {
    when(
      () => collection.updateFields(docId: docId, fields: fields),
    ).thenAnswer((_) async {});

    final result = await repository.updateFields(docId: docId, fields: fields);

    expect(result.isRight(), isTrue);
  });

  test('arrayUnion', () async {
    when(
      () => collection.arrayUnion(docId: docId, field: field, values: values),
    ).thenAnswer((_) async {});

    final result = await repository.arrayUnion(
      docId: docId,
      field: field,
      values: values,
    );

    expect(result.isRight(), isTrue);
  });

  test('arrayRemove', () async {
    when(
      () => collection.arrayRemove(docId: docId, field: field, values: values),
    ).thenAnswer((_) async {});

    final result = await repository.arrayRemove(
      docId: docId,
      field: field,
      values: values,
    );

    expect(result.isRight(), isTrue);
  });

  test('serverTimestamp', () async {
    when(
      () => collection.serverTimestamp(docId: docId, field: field),
    ).thenAnswer((_) async {});

    final result = await repository.serverTimestamp(docId: docId, field: field);

    expect(result.isRight(), isTrue);
  });

  test('where', () async {
    await expectForwarded(
      () => collection.where(
        clauses,
        orderBy: orderBy,
        limit: 2,
        getOptions: getOptions,
      ),
      [user],
      () => repository.where(
        clauses,
        orderBy: orderBy,
        limit: 2,
        getOptions: getOptions,
      ),
    );
  });

  test('whereById', () async {
    await expectForwarded<TestUser?>(
      () => collection.whereById(docId, getOptions: getOptions),
      user,
      () => repository.whereById(docId, getOptions: getOptions),
    );
  });

  group('streams', () {
    test('streamWhere', () async {
      when(
        () => collection.streamWhere(clauses, orderBy: orderBy, limit: 2),
      ).thenAnswer((_) => Stream.value([user]));

      final result = await repository
          .streamWhere(clauses, orderBy: orderBy, limit: 2)
          .first;

      expect(result.getRightOrElseNull(), [user]);
    });

    test('streamChanges', () async {
      when(
        () => collection.streamChanges(includeRemoved: true),
      ).thenAnswer((_) => Stream.value([user]));

      final result = await repository.streamChanges(includeRemoved: true).first;

      expect(result.getRightOrElseNull(), [user]);
    });

    test('streamMany', () async {
      when(
        () => collection.streamMany(docIds),
      ).thenAnswer((_) => Stream.value([user, null]));

      final result = await repository.streamMany(docIds).first;

      expect(result.getRightOrElseNull(), [user, null]);
    });

    test('streamCountWhere', () async {
      when(
        () => collection.streamCountWhere(clauses),
      ).thenAnswer((_) => Stream.value(4));

      final result = await repository.streamCountWhere(clauses).first;

      expect(result.getRightOrElseNull(), 4);
    });
  });
}
