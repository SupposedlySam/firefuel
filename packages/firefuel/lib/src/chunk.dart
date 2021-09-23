import 'package:firefuel/firefuel.dart';

enum ChunkStatus { nextAvailable, last }

/// Used to keep track of state when paginating
class Chunk<T> {
  static const int defaultLimit = 25;

  final DocumentSnapshot<T?>? cursor;
  final List<T> data;
  final int limit;
  final List<OrderBy>? orderBy;
  final List<Clause>? clauses;
  final ChunkStatus status;

  Chunk({
    required this.orderBy,
    this.clauses,
    this.limit = defaultLimit,
  })  : data = [],
        cursor = null,
        status = ChunkStatus.nextAvailable;

  Chunk.next({
    required this.data,
    required this.cursor,
    required this.orderBy,
    this.clauses,
    this.limit = defaultLimit,
  }) : status = ChunkStatus.nextAvailable;

  Chunk.last({
    required this.data,
    required this.cursor,
    required this.orderBy,
    this.clauses,
    this.limit = defaultLimit,
  }) : status = ChunkStatus.last;
}
