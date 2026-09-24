# Design decisions

Decisions with their reasons, including rejected and retracted ones. A retracted claim kept
next to its replacement teaches more than either alone. The newest entries are at the bottom.

## 2026-09-23 — 0.5 plan, after architecture and lateral review

Inputs: the flyby audit (read-only, 2026-09-23), flyby-owner's answers, the
architecture-reviewer, the creative-solutions review, and GitHub issues #18, #34, #35, #43, #62.

### D1. Build order follows seams, not features
The pitches as first written each rebuilt query lowering (05, 06, 08, and 02's fixes).
Order adopted:

1. 01 toolchain, plus silent failures (moved from 09, because `universal_io` exists only for the `print`)
2. 02a pure correctness fixes (direction, docId direction, `arrayContainsAny`, batch counter,
   count options, the multi-field range refusal)
3. 10 own the `Either` (before new `Either` signatures multiply)
4. **12 query layer**: the `FirefuelQuery<T>` value with one lowering, plus the `Chunk` fix
5. 03 instance resolution
6. 04 write vocabulary (`FieldUpdate`, the server-timestamp sentinel, one serialization path)
7. 07 transactions and multi-collection batches, plus 02 #7/#8
8. 06 collection groups
9. 05 snapshot metadata
10. 08 remaining query power (OR/AND, cursors, `limitToLast`, multi-aggregate)
11. 09 observer (it's also where late write failures go, 13)
12. 11 docs and site

### D2. The query is a value
`FirefuelQuery<T>` (clauses, orderBy, limit/limitToLast, start/end cursors) has one
lowering onto a `Query<T?>`. The orderBy rewrite moves into that lowering; today it's feature
envy on `Clause` statics. The existing `where`/`streamWhere`/`orderBy`/`limit`/... methods
stay as one-line sugar, so no caller breaks. *Rejected:* adding cursor, metadata and group
variants to every method. That multiplies features by query shapes.

### D3. Metadata: two new entry points, not a flag
A flag can't change a stream's element type. `snapshots(query)` and `docSnapshot(id)` return
`FirefuelSnapshot<R>` (`value`, `isFromCache`, `hasPendingWrites`). *Rejected:* parallel
`…Snapshots` methods (they double about 9 methods on 3 layers) and a `List` subtype that
carries metadata (it can't represent a null single document).

### D4. `replace` becomes `update` with the whole document
Firestore's `update` already fails with NOT_FOUND when the document is missing, and that
check runs **on the server at commit**. So it's atomic, it works inside a batch after a
`createById` in the same batch (#43), and it works offline. The old read-then-set was racy,
did a billed read, couldn't work in a batch, and hid a missing document behind a `void`.
**Behaviour change:** replacing a missing document is now an error (a `Left` from the
repository) instead of a silent no-op. Fields that are stored but absent from `toFirestore`'s
output survive; models are expected to serialize every field.
*Rejected:* moving `replace` onto a transaction. Transactions fail offline, which would make
#62 worse.

### D5. Keep hand-written repository delegation
The rules interfaces are generic over the return type, so a missing repository method is a
compile error, and that's worth keeping. Growth is contained by D2 instead: `where(query)` and
`snapshots(query)` replace per-shape variants. *Rejected:* `repo.run((c) => ...)` because it
can't be mocked per operation, and consumers mock repositories in bloc tests. *Deferred:*
generating the repository with a maintainer-side script (the creative review's option);
revisit if the surface keeps growing.

### D6. `Either` is ours
dartz 0.10.1 (2021) is unmaintained, and a typedef can't make two `Either` types the same, so
there's no compatibility layer to be had. It becomes a sealed `Either` in `firefuel_core` with
dartz's names (`Left`, `Right`, `left()`, `right()`, `fold`, `map`, `isLeft`, `isRight`,
`getOrElse`, `swap`, `flatMap`). flyby's only breakage is 2 test files that import dartz
directly (flyby-owner, 2026-09-23).

### D7. `Clause` becomes sealed
`Clause(field, ...)` keeps compiling and returns a field clause. `Clause.or` and `Clause.and`
return a group. The orderBy rewrite applies to top-level AND field clauses only.
*Rejected:* a type named `Filter`, which collides with cloud_firestore's.

### D9. Primary constructors: not yet (2026-09-24)
They became stable in Dart 3.13 (July 2026) and would remove boilerplate from about 20
firefuel classes. Adopting them means raising the minimum from Dart 3.10 to 3.13
(Flutter 3.47). The maintainer chose to stay on ^3.10 for wider compatibility and revisit
later. When they're adopted: a class with a primary constructor can't keep other
generative constructors (e.g. `Chunk`'s `.next`/`.last`), and `final`/`var` on ordinary
parameters becomes an error at language 3.13.

### D10. firefuel builds on package:chunk (2026-09-24)
The maintainer's `chunk` package (`Chunk<T, Cursor>`, `Chunker`) is what `paginated_builder`
builds on. firefuel had its own `Chunk`, and flyby imports both, hiding firefuel's. Decision:
update `chunk` to 2.0 (Dart 3, no `Failure` name clash with firefuel_core), then have
firefuel build on it. Release order becomes chunk 2.0 → firefuel_core → firefuel.

### D8. The server-timestamp sentinel lives in `firefuel_core`
flyby's shared model package depends on `firefuel_core` only, with no Flutter and no
cloud_firestore. That's why flyby invented a `ServerValue` enum. A const `ServerTimestamp()`
that `toJson` can return, lowered by firefuel on every write path, removes flyby's
`create`/`createById` overrides.
