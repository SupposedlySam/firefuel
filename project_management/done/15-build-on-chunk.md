# Build pagination on package:chunk

## Metadata
- **Type:** Improvement
- **Appetite:** 1 day
- **Status:** Done (2026-09-24)
- **Created:** 2026-09-24
- **Breaking:** yes (firefuel's `Chunk` is replaced)

## Problem
The maintainer's `chunk` package (`Chunk<T, Cursor>`, `Chunker`) is the pagination primitive
under `paginated_builder`. firefuel had its own, different `Chunk` and `ChunkStatus`, so an app
using both (flyby) had to `hide Chunk`, and a firefuel collection couldn't feed a
`paginated_builder` list.

## Outcome
- **chunk 1.1.0**, on branch `chore/dart-3` of SupposedlySam/chunk (pushed, not published).
  Changes: Dart ^3.0.0 (the old `<3.0.0` constraint only resolved through Dart 3's null-safety
  allowance, and its test suite no longer built), equatable >=2.0.5 <4.0.0, and a doc comment
  that stopped mid-sentence. **Non-breaking by choice** (the maintainer's pick was "2.0"): a
  breaking 2.0 would have made firefuel 0.5 unresolvable in flyby until paginated_builder also
  moved to it. Its `enum Failure` clash with firefuel_core is avoided by `show` on firefuel's
  export instead of a rename.
- firefuel depends on `chunk: ^1.0.1+1`, which is published today, so firefuel 0.5 doesn't
  wait on chunk 1.1.0.
- `paginate(FirefuelQuery, {after})` returns `Chunk<T, DocumentSnapshot<T?>>` (`FirefuelPage<T>`)
  with Chunker's semantics: a last chunk is returned unchanged, and the page size comes from the
  query, else `Chunk.defaultLimit` (50).
- `FirefuelCollection.dataChunker(query)` returns a `DataChunker<T, DocumentId>` for `Chunker`
  and paginated_builder. Each page after the first costs one read to position on the cursor's
  document. A test drives package:chunk's real `Chunker` through every page, and a mutation
  (ignoring the cursor) fails it rather than hanging it.
- Verified on the fake (373), the emulator (229 passed, 1 skipped) and the example (7).

## Not done
- `dataChunker` for collection groups. A group has no `ref.doc(id)` to position with; it would
  need a document-path cursor. No consumer has asked.
- Publishing chunk 1.1.0, and moving paginated_builder to it. Both are for the maintainer.
