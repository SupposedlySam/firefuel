import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/field_updates.dart';

/// A model whose `createdAt` is stamped by the server when it is new,
/// written the way flyby writes message pods.
class Note extends Serializable {
  const Note(this.text, {this.createdAt});

  static const fieldText = 'text';
  static const fieldCreatedAt = 'createdAt';

  final String text;
  final DateTime? createdAt;

  @override
  Map<String, dynamic> toJson() => {
    fieldText: text,
    fieldCreatedAt: createdAt ?? const ServerTimestamp(),
  };
}

class NoteCollection extends FirefuelCollection<Note> {
  NoteCollection() : super('notes');

  @override
  Note? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) return null;

    return Note(
      data[Note.fieldText] as String,
      createdAt: (data[Note.fieldCreatedAt] as Timestamp?)?.toDate(),
    );
  }

  @override
  Map<String, Object?> toFirestore(Note? model, SetOptions? options) {
    return model?.toJson() ?? {};
  }
}

void main() {
  late FakeFirebaseFirestore firestore;
  late NoteCollection notes;
  final docId = DocumentId('note');

  setUp(() {
    firestore = FakeFirebaseFirestore();
    Firefuel.initialize(firestore);
    notes = NoteCollection();
  });

  tearDown(Firefuel.reset);

  Future<Map<String, dynamic>?> stored() async {
    final snapshot = await firestore.collection('notes').doc('note').get();

    return snapshot.data();
  }

  group('$FieldUpdates.lower', () {
    test('should lower every $FieldUpdate to its FieldValue', () {
      final lowered = FieldUpdates.lower({
        'inc': const FieldUpdate.increment(2),
        'union': const FieldUpdate.arrayUnion(['a']),
        'remove': const FieldUpdate.arrayRemove(['b']),
        'delete': const FieldUpdate.delete(),
        'stamp': const FieldUpdate.serverTimestamp(),
        'plain': 7,
      });

      // FieldValue has no value equality; its toString names the operation
      // and its arguments.
      String describe(Object? value) => (value! as FieldValue).toString();

      expect(describe(lowered['inc']), '${FieldValue.increment(2)}');
      expect(describe(lowered['union']), '${FieldValue.arrayUnion(['a'])}');
      expect(describe(lowered['remove']), '${FieldValue.arrayRemove(['b'])}');
      expect(describe(lowered['delete']), '${FieldValue.delete()}');
      expect(describe(lowered['stamp']), '${FieldValue.serverTimestamp()}');
      expect(lowered['plain'], 7);
    });

    test('should lower inside nested maps and leave lists alone', () {
      const list = [ServerTimestamp()];
      final lowered = FieldUpdates.lower({
        'nested': <String, Object?>{'stamp': const ServerTimestamp()},
        'list': list,
      });

      expect(
        (lowered['nested']! as Map<String, Object?>)['stamp'],
        isA<FieldValue>(),
      );
      expect(lowered['list'], same(list));
    });
  });

  group('$ServerTimestamp returned from toJson', () {
    test('should be stamped by the server on createById', () async {
      await notes.createById(value: const Note('hi'), docId: docId);

      expect((await stored())![Note.fieldCreatedAt], isA<Timestamp>());
      expect((await notes.read(docId))!.createdAt, isNotNull);
    });

    test('should be stamped by the server on create', () async {
      final id = await notes.create(const Note('hi'));

      expect((await notes.read(id))!.createdAt, isNotNull);
    });

    test('should be stamped on updateOrCreate and update', () async {
      await notes.updateOrCreate(docId: docId, value: const Note('first'));
      await notes.update(docId: docId, value: const Note('second'));

      final data = await stored();
      expect(data![Note.fieldText], 'second');
      expect(data[Note.fieldCreatedAt], isA<Timestamp>());
    });

    test('should be stamped in a batch', () async {
      final batch = FirefuelBatch(notes);

      await batch.createById(value: const Note('batched'), docId: docId);
      await batch.commit();

      expect((await stored())![Note.fieldCreatedAt], isA<Timestamp>());
    });
  });

  group('updateFields with $FieldUpdate values', () {
    setUp(() async {
      await firestore.collection('notes').doc('note').set({
        Note.fieldText: 'seeded',
        'count': 1,
        'tags': ['a'],
        'obsolete': true,
      });
    });

    test('should combine transforms and plain sets in one write', () async {
      await notes.updateFields(
        docId: docId,
        fields: {
          'count': const FieldUpdate.increment(2),
          'tags': const FieldUpdate.arrayUnion(['b']),
          'obsolete': const FieldUpdate.delete(),
          Note.fieldText: 'plain',
        },
      );

      final data = await stored();
      expect(data!['count'], 3);
      expect(data['tags'], ['a', 'b']);
      expect(data.containsKey('obsolete'), isFalse);
      expect(data[Note.fieldText], 'plain');
    });

    test('should do the same through a batch', () async {
      final batch = FirefuelBatch(notes);
      await batch.updateFields(
        docId: docId,
        fields: {'count': const FieldUpdate.increment(5)},
      );
      await batch.commit();

      expect((await stored())!['count'], 6);
    });

    test('increment should add to the stored number', () async {
      await notes.increment(docId: docId, field: 'count', by: 4);

      expect((await stored())!['count'], 5);
    });

    test('deleteField should remove the field', () async {
      await notes.deleteField(docId: docId, field: 'obsolete');

      final data = await stored();
      expect(data!.containsKey('obsolete'), isFalse);
      expect(data['count'], 1);
    });

    test('the repository should forward increment and deleteField', () async {
      final repository = _NoteRepository(notes);

      final incremented = await repository.increment(
        docId: docId,
        field: 'count',
        by: 1,
      );
      final deleted = await repository.deleteField(
        docId: docId,
        field: 'obsolete',
      );

      expect(incremented.isRight(), isTrue);
      expect(deleted.isRight(), isTrue);
      final data = await stored();
      expect(data!['count'], 2);
      expect(data.containsKey('obsolete'), isFalse);
    });
  });
}

class _NoteRepository extends FirefuelRepository<Note> {
  _NoteRepository(Collection<Note> collection) : super(collection: collection);
}
