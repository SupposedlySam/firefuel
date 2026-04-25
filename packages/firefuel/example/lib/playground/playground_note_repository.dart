import 'package:firefuel/firefuel.dart';

import 'playground_note.dart';
import 'playground_note_collection.dart';

class PlaygroundNoteRepository extends FirefuelRepository<PlaygroundNote> {
  PlaygroundNoteRepository({required PlaygroundNoteCollection collection})
      : _collection = collection,
        super(collection: collection);

  final PlaygroundNoteCollection _collection;

  Future<Either<Failure, DocumentId>> createTimestampedNote({
    required PlaygroundNote note,
  }) {
    return guard(() async {
      final docId = await _collection.create(note);
      await _collection.serverTimestamp(
        docId: docId,
        field: PlaygroundNote.fieldUpdatedAt,
      );

      return docId;
    });
  }

  Future<Either<Failure, PlaygroundNote>> readOrCreateWelcomeNote() {
    return guard(() {
      return _collection.readOrCreate(
        createValue: const PlaygroundNote(
          rating: 4.8,
          tags: ['welcome'],
          title: 'Welcome note',
          views: 10,
        ),
        docId: DocumentId('welcome'),
      );
    });
  }
}
