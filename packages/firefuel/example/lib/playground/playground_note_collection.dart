import 'package:firefuel/firefuel.dart';

import 'playground_note.dart';

class PlaygroundNoteCollection extends FirefuelCollection<PlaygroundNote> {
  PlaygroundNoteCollection() : super('playgroundNotes');

  @override
  PlaygroundNote? fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) return null;

    return PlaygroundNote.fromJson(data, snapshot.id);
  }

  @override
  Map<String, Object?> toFirestore(
    PlaygroundNote? model,
    SetOptions? options,
  ) {
    return model?.toJson() ?? <String, Object?>{};
  }
}
