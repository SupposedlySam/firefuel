# Correctness: things firefuel says it does and does not

## Metadata
- **Type:** Fix
- **Appetite:** 2 days
- **Status:** Bet (started 2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** behaviour changes in 1, 3 and 6 (each one is currently wrong)

## Problem
A library whose promise is "simple, intuitive, consistent" cannot have methods that quietly
do something other than what their names say. Every item below was found by reading the
source, and each one has a failing test to prove it before the fix.

| # | Defect | Where | Consequence |
|---|---|---|---|
| 1 | `OrderDirection.newestToOldest` → `asc`, `oldestToNewest` → `desc` | `order_by.dart` | Every sort using those names comes back reversed. A test pins the wrong behaviour. |
| 1b | `OrderBy.docId(dir)` is `const`, skips `toAscDesc`; `sort()` only checks `== desc` | `order_by.dart`, `query_extensions.dart` | `OrderBy.docId(OrderDirection.zToA)` sorts ascending |
| 2 | `paginate` builds the next `Chunk` without `clauses` or `limit` | `firefuel_collection.dart` | Page 2 onward ignores your filters and falls back to 25 per page |
| 3 | `Clause.arrayContainsAny` is accepted but never passed to `Query.where` | `query_extensions.dart` | That clause is dropped silently, so the query returns everything |
| 4 | Batch auto-commit off-by-one | `firefuel_batch.dart` | Commits 499, then counts the rolled-over op as 0. `totalTransactionsCommitted` is wrong. The existing test pins the wrong count. |
| 5 | `countAll`/`countWhere` accept `GetOptions` and ignore it | `firefuel_collection.dart` | A parameter that does nothing. Aggregations take `AggregateSource`. |
| 6 | `MoreThanOneFieldInRangeClauseException` | `firefuel_collection.dart` | Firestore has supported range filters on up to 10 fields since 2024, so firefuel refuses valid queries |
| 7 | `FirefuelBatch.replace` reads when the op is queued, not at commit (#43) | `firefuel_batch.dart` | `createById` + `replace` in one batch drops the replace silently |
| 8 | `readOrCreate`, `replace` are read-then-write, not atomic | `firefuel_collection.dart` | A concurrent writer can be overwritten |

## Criteria
### Must have
- A red test for every row, turned green by the fix. Where an existing test asserts the bug,
  change that test in the same commit and say so.
- 1–6 fixed.
- 7: `replace` inside a batch should stop reading and write with `update` semantics
  (`set` with the whole document plus an existence precondition isn't available in a batch).
  Decide with the reviewers.
- 8: implement `readOrCreate` and `replace` with a transaction once pitch 07 lands.

## Boundaries
### Out of scope
- Re-deriving whether Firestore still forbids `orderBy` on an equality-filtered field. The
  rewrite is harmless, so it stays until it is measured against the emulator.

## How it fails
- 1 changes results for anyone who compensated for the bug. flyby's only uses are dead code
  (confirmed by its audit). The CHANGELOG must call it out as **BREAKING (fix)**.
