import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_collection.dart';
import '../utils/expected_failure.dart';
import '../utils/test_user.dart';

void main() {
  final defaultUser = TestUser('testUser');
  late MockCollection mockCollection;
  late FirefuelRepository testRepository;

  setUp(() {
    mockCollection = MockCollection();
    testRepository = TestRepository(collection: mockCollection);
  });

  group('#create', () {
    test('should return Right when successful', () async {
      mockCollection.initialize(
          onCreate: () => DocumentId('h34jfhg43fiuy3gv4'));

      final createResult = await testRepository.create(value: defaultUser);

      expect(createResult, isA<Right<Failure, DocumentId>>());
    });

    test('should return Left when not successful', () async {
      mockCollection.initialize(onCreate: () => throw ExpectedFailure());

      final createResult = await testRepository.create(value: defaultUser);

      expect(createResult, isA<Left<Failure, DocumentId>>());
    });
  });

  group('#read', () {}, skip: true);
  group('#readAsStream', () {}, skip: true);
  group('#update', () {}, skip: true);
  group('#delete', () {}, skip: true);
}

class TestRepository<T extends Serializable> extends FirefuelRepository<T> {
  TestRepository({required Collection<T> collection})
      : super(collection: collection);
}
