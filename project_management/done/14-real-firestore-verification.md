# Verify firefuel against real Firestore

## Metadata
- **Type:** Infrastructure
- **Appetite:** 2 days
- **Status:** Done (2026-09-24)
- **Created:** 2026-09-24
- **Breaking:** no

## Problem
Every firefuel test runs on fake_cloud_firestore. The maintainer gave up on an earlier suite built
on the fake because it broke where real Firestore worked. Building 0.5 found three places the fake
differs from Firestore: it applies query operations in call order, it notifies listeners per
reference type, and it doesn't roll back a failed transaction. A green run against the fake proves
the code agrees with the fake, not with Firestore.

## Decision (maintainer, 2026-09-24)
- The Firestore **emulator** is the primary real backend. It runs locally and in CI on every push.
- A **new dedicated Firebase project** runs the same suite live, on demand. CI doesn't run it and
  holds no credentials. The live run catches index requirements and production limits the emulator
  doesn't enforce.

## Shaping
- The same test files run against both backends. They get Firestore from one helper
  (`testFirestore()`), which returns the fake unless an integration run installs a real backend.
- `packages/firefuel_integration` is an unpublished Flutter app (macOS; cloud_firestore has no Linux
  desktop support). Its `integration_test` imports firefuel's test files and runs them with the real
  backend installed.
- Between tests the database is wiped: with the emulator's REST reset, or live with a scoped
  recursive delete in the dedicated project.
- Tests that are meaningful only on the fake are tagged, and listed here with the reason for each.
  Examples: mocks, and "another instance" isolation, which needs a second database.

## How it fails
- The emulator doesn't enforce composite indexes. Only the live run shows a missing index.
- Live runs are slow (network per test) and count against the free quota.

## Outcome (2026-09-24)
- **Emulator** (macOS and iOS simulator, CI `real-firestore` job): 225 passed, 1 skipped (a named
  emulator gap, `orderBy(documentId, desc)`).
- **Live** `firefuel-integration` (iOS simulator): 218 passed, 8 skipped. The skips are the tests
  that need a second isolated Firestore.
- **What the fake hid.** 19 tests passed on the fake and failed on the emulator. None was a
  firefuel bug. They were queries Firestore rejects (two `!=`, a model as a filter value),
  one-event-per-write stream assumptions, insertion-order assumptions, and zero-latency
  assumptions. All were rewritten to hold on both backends.
- **What the emulator hid.** Composite indexes, which production needs for 7 query shapes and 2
  collection-group fields (`firestore.indexes.json`). They're now documented in the API guide.
- **Mutation-checked.** Restoring the 0.4.7 `OrderDirection` mapping fails the four direction tests
  on the emulator.
- **Things learned.** Firebase Auth on macOS needs a provisioned keychain entitlement, so live runs
  use the iOS simulator. Password sign-in per test hit Auth's quota, so runs use a per-run custom
  token instead. A shared Firestore instance leaks between tests.
- **Not done.** Live runs aren't in CI (by decision; no credential in CI).
