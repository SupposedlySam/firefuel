import 'package:equatable/equatable.dart';

import 'package:firefuel/firefuel.dart';
import 'package:firefuel/src/utils/query_extensions.dart';

/// A complete description of which documents to read, as a value.
///
/// Every query-shaped read in firefuel (`where`, `orderBy`, `limit`,
/// `paginate` and their stream variants) lowers through [applyTo], so a
/// filter, sort, cursor or limit is applied the same way whichever method
/// you call. Build one when the convenience methods cannot express what you
/// need, and pass it to `query` or `streamQuery`:
///
/// ```dart
/// final lastFive = await notes.query(
///   FirefuelQuery(
///     clauses: [Clause(Note.fieldPinned, isEqualTo: true)],
///     orderBy: [OrderBy(field: Note.fieldCreatedAt)],
///     limitToLast: 5,
///   ),
/// );
/// ```
///
/// A query is immutable; derive variations with [copyWith].
class FirefuelQuery extends Equatable {
  /// Creates a query. Every part is optional; an empty query reads the whole
  /// collection.
  ///
  /// [limit] and [limitToLast] are mutually exclusive. [limitToLast] and
  /// cursors ([start], [end]) require at least one [orderBy].
  FirefuelQuery({
    this.clauses = const [],
    this.orderBy = const [],
    this.limit,
    this.limitToLast,
    this.start,
    this.end,
  }) {
    if (limit != null && limitToLast != null) {
      throw ArgumentError('A query takes limit or limitToLast, not both');
    }
    final needsOrder = limitToLast != null || start != null || end != null;
    if (needsOrder && orderBy.isEmpty) {
      // Firestore anchors limitToLast and cursors on the sort order; without
      // one it rejects the query on the server. Fail here, where the
      // mistake is made, with a name that says what is missing.
      throw MissingValueException(OrderBy);
    }
  }

  /// Filters every returned document must match (combined with AND).
  final List<Clause> clauses;

  /// Sort order, first entry first.
  ///
  /// With a range [Clause], Firestore requires the first orderBy to be on a
  /// range field; [applyTo] moves or inserts it for you. Fields filtered by
  /// equality or `whereIn` are dropped from the order, which Firestore
  /// forbids.
  final List<OrderBy> orderBy;

  /// Returns at most this many documents from the start of the order.
  final int? limit;

  /// Returns at most this many documents from the end of the order, still
  /// in [orderBy] order.
  final int? limitToLast;

  /// Where results begin, by the values of the [orderBy] fields.
  final StartCursor? start;

  /// Where results end, by the values of the [orderBy] fields.
  final EndCursor? end;

  /// A copy with the given parts replaced.
  ///
  /// Nullable parts cannot be cleared through this method; build a new
  /// query instead.
  FirefuelQuery copyWith({
    List<Clause>? clauses,
    List<OrderBy>? orderBy,
    int? limit,
    int? limitToLast,
    StartCursor? start,
    EndCursor? end,
  }) {
    return FirefuelQuery(
      clauses: clauses ?? this.clauses,
      orderBy: orderBy ?? this.orderBy,
      limit: limit ?? this.limit,
      limitToLast: limitToLast ?? this.limitToLast,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  /// The sort order Firestore will accept for [clauses].
  ///
  /// The rewrite only applies when there are both clauses and an order:
  /// ordering without filters is always valid as given.
  List<OrderBy> get effectiveOrderBy {
    final fieldToMatch = Clause.fieldMatchingRangeOrderingRule(
      clauses,
      orderBy: orderBy,
    );
    // Only top-level field clauses take part in Firestore's ordering rules;
    // a query filtered solely by OR/AND groups keeps the order given.
    if (fieldToMatch == null || orderBy.isEmpty) return orderBy;

    final withRangeFieldFirst = OrderBy.moveOrCreateMatchingField(
      fieldToMatch: fieldToMatch,
      orderBy: orderBy,
      isRangeComparison: Clause.hasRangeComparison(clauses),
    );

    return OrderBy.removeEqualtyAndInMatchingFields(
          fieldsToMatch: Clause.getEqualityOrInComparisonFields(clauses),
          orderBy: withRangeFieldFirst,
          isEqualityOrInComparison: Clause.hasEqualityOrInComparison(clauses),
        ) ??
        const [];
  }

  /// Applies this query to [base]: filters, then order, then cursors, then
  /// limits, which is the order Firestore requires them in.
  ///
  /// [startAfterDocument] is the page cursor `paginate` uses. It takes the
  /// place of [start] and must go through here rather than onto the result:
  /// a cursor applied after the limit selects from the wrong documents
  /// (fake_cloud_firestore applies operations in call order and shows it).
  Query<R> applyTo<R>(
    Query<R> base, {
    DocumentSnapshot<Object?>? startAfterDocument,
  }) {
    var query = base.filter(clauses).sort(effectiveOrderBy);

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    query = switch (start) {
      _ when startAfterDocument != null => query,
      null => query,
      StartAt(:final values) => query.startAt(values),
      StartAfter(:final values) => query.startAfter(values),
    };
    query = switch (end) {
      null => query,
      EndAt(:final values) => query.endAt(values),
      EndBefore(:final values) => query.endBefore(values),
    };

    if (limit case final limit?) query = query.limit(limit);
    if (limitToLast case final limitToLast?) {
      query = query.limitToLast(limitToLast);
    }

    return query;
  }

  @override
  List<Object?> get props => [clauses, orderBy, limit, limitToLast, start, end];
}

/// Where a [FirefuelQuery]'s results begin.
///
/// [values] line up with the query's `orderBy` fields, first to first.
sealed class StartCursor extends Equatable {
  const StartCursor(this.values);

  /// Begin at the first document matching [values], inclusive.
  const factory StartCursor.at(List<Object?> values) = StartAt;

  /// Begin just after the documents matching [values].
  const factory StartCursor.after(List<Object?> values) = StartAfter;

  final List<Object?> values;

  /// Led by the type: equatable 3 no longer compares `runtimeType`, and
  /// the at/after (or at/before) variants hold the same values.
  @override
  List<Object?> get props => [runtimeType, values];
}

/// Inclusive start cursor; see [StartCursor.at].
final class StartAt extends StartCursor {
  const StartAt(super.values);
}

/// Exclusive start cursor; see [StartCursor.after].
final class StartAfter extends StartCursor {
  const StartAfter(super.values);
}

/// Where a [FirefuelQuery]'s results end.
///
/// [values] line up with the query's `orderBy` fields, first to first.
sealed class EndCursor extends Equatable {
  const EndCursor(this.values);

  /// End at the last document matching [values], inclusive.
  const factory EndCursor.at(List<Object?> values) = EndAt;

  /// End just before the documents matching [values].
  const factory EndCursor.before(List<Object?> values) = EndBefore;

  final List<Object?> values;

  /// Led by the type: equatable 3 no longer compares `runtimeType`, and
  /// the at/after (or at/before) variants hold the same values.
  @override
  List<Object?> get props => [runtimeType, values];
}

/// Inclusive end cursor; see [EndCursor.at].
final class EndAt extends EndCursor {
  const EndAt(super.values);
}

/// Exclusive end cursor; see [EndCursor.before].
final class EndBefore extends EndCursor {
  const EndBefore(super.values);
}
