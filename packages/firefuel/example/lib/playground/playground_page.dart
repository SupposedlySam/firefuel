import 'package:flutter/material.dart';

import 'package:firefuel/firefuel.dart';

import 'playground_note.dart';
import 'playground_note_collection.dart';
import 'playground_note_repository.dart';

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  late final PlaygroundNoteCollection _collection;
  late final PlaygroundNoteRepository _repository;
  late final Stream<List<PlaygroundNote>> _notesStream;
  late final PageController _actionPageController;

  var _createdNotes = 0;
  var _isBusy = false;
  var _lastResult = 'Tap a card action to run a Firefuel method.';

  @override
  void initState() {
    super.initState();

    _collection = PlaygroundNoteCollection();
    _repository = PlaygroundNoteRepository(collection: _collection);
    _actionPageController = PageController(viewportFraction: 0.9);
    _notesStream = _collection.streamOrdered([
      OrderBy(field: PlaygroundNote.fieldTitle),
    ]);

    _runAction(label: 'Seeded sample notes', action: _seedSampleNotes);
  }

  @override
  void dispose() {
    _actionPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const actionTrayReservedHeight = 380.0;
    final featureCards = [
      _FeatureCard(
        apis: const ['FirefuelBatch.create()'],
        description: 'Create sample documents in one commit.',
        title: 'Seed sample data',
        onPressed: () =>
            _runAction(label: 'Seeded sample notes', action: _seedSampleNotes),
      ),
      _FeatureCard(
        apis: const [
          'FirefuelRepository.create()',
          'FirefuelRepository.serverTimestamp()',
        ],
        description: 'Create a note through a repository and timestamp it.',
        title: 'Create a document',
        onPressed: () => _runAction(
          label: 'Created a timestamped note',
          action: _createTimestampedNote,
        ),
      ),
      _FeatureCard(
        apis: const ['FirefuelRepository.readOrCreate()'],
        description: 'Fetch a known document, or create it if missing.',
        title: 'Read or create',
        onPressed: () => _runAction(
          label: 'Read or created the welcome note',
          action: _readOrCreateWelcomeNote,
        ),
      ),
      _FeatureCard(
        apis: const [
          'FirefuelCollection.update()',
          'FirefuelCollection.updateFields()',
          'FirefuelCollection.serverTimestamp()',
        ],
        description: 'Update one model, then update individual fields.',
        title: 'Update fields',
        onPressed: () => _runAction(
          label: 'Pinned and updated the first note',
          action: _pinFirstNote,
        ),
      ),
      _FeatureCard(
        apis: const [
          'FirefuelCollection.arrayUnion()',
          'FirefuelCollection.arrayRemove()',
        ],
        description: 'Add and remove tags with Firestore transforms.',
        title: 'Array transforms',
        onPressed: () => _runAction(
          label: 'Toggled a tag on the first note',
          action: _toggleTag,
        ),
      ),
      _FeatureCard(
        apis: const [
          'FirefuelCollection.where()',
          'FirefuelCollection.countWhere()',
          'FirefuelCollection.sumAll()',
          'FirefuelCollection.averageAll()',
        ],
        description: 'Run filtered reads and aggregate queries.',
        title: 'Query and aggregate',
        onPressed: () =>
            _runAction(label: 'Calculated query stats', action: _showStats),
      ),
      _FeatureCard(
        apis: const ['FirefuelCollection.paginate()', 'Chunk'],
        description: 'Load one small page at a time.',
        title: 'Paginate',
        onPressed: () =>
            _runAction(label: 'Loaded the first page', action: _showFirstPage),
      ),
      _FeatureCard(
        apis: const [
          'FirefuelCollection.readMany()',
          'FirefuelCollection.streamMany()',
        ],
        description: 'Read or stream a known set of document IDs.',
        title: 'Multi-document reads',
        onPressed: () => _runAction(
          label: 'Read many selected notes',
          action: _readManyNotes,
        ),
      ),
      _FeatureCard(
        apis: const ['Clause.or()', 'FirefuelQuery', 'limitToLast'],
        description: 'Match either condition, then keep the last two.',
        title: 'OR queries and cursors',
        onPressed: () =>
            _runAction(label: 'Ran an OR query', action: _showOrQuery),
      ),
      _FeatureCard(
        apis: const ['FirefuelCollection.aggregate()'],
        description: 'Count, sum and average in one request.',
        title: 'One-shot aggregate',
        onPressed: () =>
            _runAction(label: 'Aggregated in one call', action: _aggregate),
      ),
      _FeatureCard(
        apis: const ['FieldUpdate', 'updateFields()'],
        description: 'Increment, tag and stamp a note in one atomic write.',
        title: 'Field updates',
        onPressed: () => _runAction(
          label: 'Applied field updates',
          action: _applyFieldUpdates,
        ),
      ),
      _FeatureCard(
        apis: const ['Firefuel.runTransaction()', 'transaction.of()'],
        description: 'Read two notes and move a view between them atomically.',
        title: 'Transaction',
        onPressed: () =>
            _runAction(label: 'Ran a transaction', action: _moveAView),
      ),
      _FeatureCard(
        apis: const ['FirefuelCollection.snapshots()', 'ListenOptions'],
        description: 'See what changed and whether it came from the cache.',
        title: 'Snapshot metadata',
        onPressed: () =>
            _runAction(label: 'Read a snapshot', action: _showSnapshot),
      ),
      _FeatureCard(
        apis: const ['FirefuelCollection.delete()'],
        description: 'Remove the newest demo-created note.',
        title: 'Delete',
        onPressed: () => _runAction(
          label: 'Deleted the newest demo note',
          action: _deleteNewestDemoNote,
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Firefuel Playground')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              actionTrayReservedHeight,
            ),
            children: [
              Text(
                'Small, copyable demos for the Firefuel API.',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Run the demos below and watch this live collection update.',
              ),
              const SizedBox(height: 16),
              _NotesCard(notesStream: _notesStream),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: _ActionTray(
                controller: _actionPageController,
                featureCards: featureCards,
                isBusy: _isBusy,
                message: _lastResult,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runAction({
    required Future<String> Function() action,
    required String label,
  }) async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _lastResult = '$label...';
    });

    try {
      final result = await action();
      if (!mounted) return;

      setState(() => _lastResult = result);
    } on Object catch (error) {
      if (!mounted) return;

      setState(() => _lastResult = 'Something went wrong: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<String> _seedSampleNotes() async {
    final count = await _collection.countAll();
    if (count > 0) return 'Sample notes already exist.';

    final batch = FirefuelBatch(_collection);
    await batch.createById(
      docId: DocumentId('welcome'),
      value: const PlaygroundNote(
        pinned: true,
        rating: 4.8,
        tags: ['intro', 'pinned'],
        title: 'Welcome note',
        views: 12,
      ),
    );
    await batch.createById(
      docId: DocumentId('queries'),
      value: const PlaygroundNote(
        rating: 4.3,
        tags: ['query'],
        title: 'Query examples',
        views: 8,
      ),
    );
    await batch.createById(
      docId: DocumentId('transforms'),
      value: const PlaygroundNote(
        rating: 4.6,
        tags: ['tags'],
        title: 'Field transforms',
        views: 5,
      ),
    );
    await batch.commit();

    return 'Created 3 notes with FirefuelBatch.';
  }

  Future<String> _createTimestampedNote() async {
    _createdNotes++;
    final result = await _repository.createTimestampedNote(
      note: PlaygroundNote(
        rating: 4 + (_createdNotes % 10) / 10,
        tags: const ['created'],
        title: 'Created note $_createdNotes',
        views: _createdNotes,
      ),
    );

    return result.fold(
      (failure) => 'Repository returned a failure: ${failure.error}',
      (docId) => 'Created ${docId.docId} and wrote a server timestamp.',
    );
  }

  Future<String> _readOrCreateWelcomeNote() async {
    final result = await _repository.readOrCreateWelcomeNote();

    return result.fold(
      (failure) => 'Repository returned a failure: ${failure.error}',
      (note) => 'Loaded "${note.title}" with readOrCreate.',
    );
  }

  Future<String> _pinFirstNote() async {
    final note = await _firstNote();
    final docId = switch (note?.docId) {
      final id? => DocumentId(id),
      null => null,
    };
    if (note == null || docId == null) return 'Create a note first.';
    await _collection.update(
      docId: docId,
      value: note.copyWith(views: note.views + 1),
    );
    await _collection.updateFields(
      docId: docId,
      fields: {PlaygroundNote.fieldPinned: true},
    );
    await _collection.serverTimestamp(
      docId: docId,
      field: PlaygroundNote.fieldUpdatedAt,
    );

    return 'Updated "${note.title}" with update, updateFields, and timestamp.';
  }

  Future<String> _toggleTag() async {
    final note = await _firstNote();
    final docId = switch (note?.docId) {
      final id? => DocumentId(id),
      null => null,
    };
    if (note == null || docId == null) return 'Create a note first.';
    if (note.tags.contains('playground')) {
      await _collection.arrayRemove(
        docId: docId,
        field: PlaygroundNote.fieldTags,
        values: ['playground'],
      );
      return 'Removed the "playground" tag from "${note.title}".';
    }

    await _collection.arrayUnion(
      docId: docId,
      field: PlaygroundNote.fieldTags,
      values: ['playground'],
    );
    return 'Added the "playground" tag to "${note.title}".';
  }

  Future<String> _showStats() async {
    final pinned = await _collection.where([
      Clause(PlaygroundNote.fieldPinned, isEqualTo: true),
    ]);
    final pinnedCount = await _collection.countWhere([
      Clause(PlaygroundNote.fieldPinned, isEqualTo: true),
    ]);
    final totalViews = await _collection.sumAll(PlaygroundNote.fieldViews);
    final averageRating = await _collection.averageAll(
      PlaygroundNote.fieldRating,
    );

    return 'Pinned: $pinnedCount (${pinned.length} read), '
        'views: ${totalViews ?? 0}, avg rating: ${averageRating ?? 0}.';
  }

  Future<String> _showOrQuery() async {
    final notes = await _collection.query(
      FirefuelQuery(
        clauses: [
          Clause.or([
            Clause(PlaygroundNote.fieldPinned, isEqualTo: true),
            Clause(PlaygroundNote.fieldViews, isGreaterThan: 6),
          ]),
        ],
        orderBy: [OrderBy(field: PlaygroundNote.fieldTitle)],
        limitToLast: 2,
      ),
    );

    return 'Pinned or popular, last two by title: '
        '${notes.map((note) => note.title).join(', ')}';
  }

  Future<String> _aggregate() async {
    final stats = await _collection.aggregate(
      FirefuelQuery(),
      count: true,
      sums: [PlaygroundNote.fieldViews],
      averages: [PlaygroundNote.fieldRating],
    );

    return '${stats.count} notes, '
        '${stats.sums[PlaygroundNote.fieldViews] ?? 0} views, '
        'avg rating ${stats.averages[PlaygroundNote.fieldRating] ?? 0}.';
  }

  Future<String> _applyFieldUpdates() async {
    final note = await _firstNote();
    final id = note?.docId;
    if (note == null || id == null) return 'Create a note first.';

    await _collection.updateFields(
      docId: DocumentId(id),
      fields: {
        PlaygroundNote.fieldViews: const FieldUpdate.increment(10),
        PlaygroundNote.fieldTags: const FieldUpdate.arrayUnion(['updated']),
        PlaygroundNote.fieldUpdatedAt: const ServerTimestamp(),
      },
    );

    return 'Added 10 views, a tag and a timestamp to "${note.title}" at once.';
  }

  Future<String> _moveAView() async {
    final notes = await _collection.orderBy([
      OrderBy(field: PlaygroundNote.fieldTitle),
    ], limit: 2);
    if (notes case [
      PlaygroundNote(docId: final fromDocId?),
      PlaygroundNote(docId: final toDocId?),
    ]) {
      return _moveAViewBetween(DocumentId(fromDocId), DocumentId(toDocId));
    }
    return 'Seed at least two notes first.';
  }

  Future<String> _moveAViewBetween(DocumentId fromId, DocumentId toId) {
    return Firefuel.runTransaction((transaction) async {
      final scope = transaction.of(_collection);
      final from = await scope.read(fromId);
      final to = await scope.read(toId);
      if (from == null || to == null) return 'A note disappeared; try again.';
      if (from.views == 0) return '"${from.title}" has no views to give.';

      scope
        ..update(
          docId: fromId,
          value: from.copyWith(views: from.views - 1),
        )
        ..update(
          docId: toId,
          value: to.copyWith(views: to.views + 1),
        );

      return 'Moved a view from "${from.title}" to "${to.title}".';
    });
  }

  Future<String> _showSnapshot() async {
    final snapshot = await _collection
        .snapshots(
          FirefuelQuery(),
          options: const ListenOptions(includeMetadataChanges: true),
        )
        .first;

    return '${snapshot.value.length} notes, ${snapshot.changes.length} '
        'changes, fromCache: ${snapshot.isFromCache}, '
        'pendingWrites: ${snapshot.hasPendingWrites}.';
  }

  Future<String> _showFirstPage() async {
    final page = await _collection.paginate(
      Chunk<PlaygroundNote>(
        limit: 2,
        orderBy: [OrderBy(field: PlaygroundNote.fieldTitle)],
      ),
    );
    final titles = page.data.map((note) => note.title).join(', ');

    return 'First page (${page.status}): $titles';
  }

  Future<String> _readManyNotes() async {
    final notes = await _collection.orderBy([
      OrderBy(field: PlaygroundNote.fieldTitle),
    ]);
    final docIds = notes
        .map((note) => note.docId)
        .whereType<String>()
        .take(2)
        .map(DocumentId.new)
        .toList();

    if (docIds.isEmpty) return 'Create a note first.';

    final selected = await _collection.readMany(docIds);
    final titles = selected
        .whereType<PlaygroundNote>()
        .map((note) => note.title)
        .join(', ');

    return 'readMany returned: $titles';
  }

  Future<String> _deleteNewestDemoNote() async {
    final notes = await _collection.orderBy([
      OrderBy(field: PlaygroundNote.fieldTitle, direction: OrderDirection.desc),
    ]);
    final demoNote = notes
        .where((note) => note.title.startsWith('Created note'))
        .firstOrNull();

    if (demoNote case PlaygroundNote(:final title, docId: final id?)) {
      await _collection.delete(DocumentId(id));
      return 'Deleted "$title".';
    }
    return 'Create a demo note before deleting one.';
  }

  Future<PlaygroundNote?> _firstNote() async {
    final notes = await _collection.orderBy([
      OrderBy(field: PlaygroundNote.fieldTitle),
    ]);

    return notes.firstOrNull();
  }
}

extension _FirstOrNullX<T> on Iterable<T> {
  T? firstOrNull() {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;

    return iterator.current;
  }
}

class _ActionTray extends StatelessWidget {
  const _ActionTray({
    required this.controller,
    required this.featureCards,
    required this.isBusy,
    required this.message,
  });

  final PageController controller;
  final List<Widget> featureCards;
  final bool isBusy;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: colorScheme.shadow.withValues(alpha: 0.12),
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusCard(isBusy: isBusy, message: message),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Demos', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 8),
                Text(
                  'Swipe to choose an action',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: controller,
                itemCount: featureCards.length,
                padEnds: false,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: featureCards[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.apis,
    required this.description,
    required this.onPressed,
    required this.title,
  });

  final List<String> apis;
  final String description;
  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Expanded(child: Text(description)),
            const SizedBox(height: 8),
            Text('Uses', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return _ApiReferencePill(api: apis[index]);
                },
                itemCount: apis.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 8);
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                key: ValueKey('$title demo button'),
                onPressed: onPressed,
                child: const Text('Run demo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiReferencePill extends StatelessWidget {
  const _ApiReferencePill({required this.api});

  final String api;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.code, color: colorScheme.onSurfaceVariant, size: 16),
            const SizedBox(width: 6),
            Text(
              api,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.isBusy, required this.message});

  final bool isBusy;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: isBusy
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.info_outline),
        title: const Text('Last result'),
        subtitle: Text(message),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notesStream});

  final Stream<List<PlaygroundNote>> notesStream;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live notes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            StreamBuilder<List<PlaygroundNote>>(
              stream: notesStream,
              builder: (context, snapshot) {
                final notes = snapshot.data ?? const <PlaygroundNote>[];
                if (notes.isEmpty) return const Text('No notes yet.');

                return Column(
                  children: [
                    for (final note in notes)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          note.pinned ? Icons.push_pin : Icons.notes,
                        ),
                        title: Text(note.title),
                        subtitle: Text(
                          'views: ${note.views}, rating: ${note.rating}, '
                          'tags: ${note.tags.join(', ')}',
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
