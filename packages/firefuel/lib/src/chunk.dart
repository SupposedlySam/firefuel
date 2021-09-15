import 'package:firefuel/firefuel.dart';

enum ChunkStatus { starting, nextAvailable, last }

/// Used to keep track of state when paginating
class Chunk<T> {
  static const int defaultLimit = 25;

  final DocumentSnapshot? cursor;
  final List<T> data;
  final int limit;
  final String? orderByField;
  final List<Clause>? clauses;
  final ChunkStatus status;

  Chunk({
    this.orderByField,
    this.clauses,
    this.limit = defaultLimit,
  })  : data = [],
        cursor = null,
        status = ChunkStatus.starting;

  Chunk.next({
    required this.data,
    required this.cursor,
    this.orderByField,
    this.clauses,
    this.limit = defaultLimit,
  }) : status = ChunkStatus.nextAvailable;

  Chunk.last({
    required this.data,
    required this.cursor,
    this.orderByField,
    this.clauses,
    this.limit = defaultLimit,
  }) : status = ChunkStatus.last;
}
