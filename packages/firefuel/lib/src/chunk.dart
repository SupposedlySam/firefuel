import 'package:firefuel/firefuel.dart';

enum ChunkStatus { starting, nextAvailable, last }

/// Used to keep track of state when paginating
class Chunk<T> {
  static const int _defaultLimit = 25;

  final DocumentSnapshot? cursor;
  final List<T> data;
  final int limit;
  final String? orderByField;
  final List<Clause>? whereClauses;
  final ChunkStatus status;

  Chunk({
    this.orderByField,
    this.whereClauses,
    this.limit = _defaultLimit,
  })  : data = [],
        cursor = null,
        status = ChunkStatus.starting;

  Chunk.next({
    required this.data,
    required this.cursor,
    this.orderByField,
    this.whereClauses,
    this.limit = _defaultLimit,
  }) : status = ChunkStatus.nextAvailable;

  Chunk.last({
    required this.data,
    required this.cursor,
    this.orderByField,
    this.whereClauses,
    this.limit = _defaultLimit,
  }) : status = ChunkStatus.last;
}
