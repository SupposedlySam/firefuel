# firefuel

A typed data layer over `cloud_firestore` for Flutter. Its values are **simple, intuitive,
consistent**: every Firestore capability an app needs should be reachable *through* firefuel,
with one shape across collections, groups, repositories, batches and transactions.

## Layout

- `packages/firefuel_core`: pure Dart (`Serializable`, `DocumentId`, `Failure`, `Either`,
  `FieldUpdate`). No Flutter, no Firestore. Model packages depend on it alone.
- `packages/firefuel`: the library. `packages/firefuel/example` is a playground app.
- `docs/`: the docsify site. **GitHub Pages serves it from `main`; pushing to `main` deploys
  the docs.** Work on branches.
- `project_management/`: Shape Up pitches (`pitches/` → `bet/` → `done/`), `DESIGN.md`
  (decisions, including rejected ones) and `pass-through.md` (every cloud_firestore capability:
  exposed, planned, or declined with a reason).

## Working

- `llms.txt` (a symlink to `docs/llms.txt`, served at `firefueldocs.com/llms.txt`) is the agent-facing
  guide. Keep it in step with the API: its snippets were compile-checked against 0.5.0; recheck
  them when signatures change.
- A pub workspace: `flutter pub get` at the root. Flutter is pinned in `.fvmrc` (use `fvm`).
- Checks that CI runs (`.github/workflows/ci.yaml`):
  `dart format --set-exit-if-changed packages/firefuel/{lib,test,example/lib,example/test} packages/firefuel_core`,
  `dart analyze --fatal-infos`, then `dart test` in firefuel_core and `flutter test` in
  firefuel and example.
- Don't run `dart format` over `packages/firefuel/bricks` or `brick_oven`: they're mustache templates.
- Conventional commits, scoped by package where it helps: `feat(firefuel):`,
  `fix(firefuel_core):`, `docs:`, `chore:`. Use `!` and a `BREAKING CHANGE:` footer for breaks.

## Null safety

No `!` (null assertion) in `packages/*/lib`; CI enforces it (`tool/check_null_assertions.sh`).
A `!` crashes for whichever caller the author didn't picture. Instead, use a pattern
(`if (x case final y?)`, a `switch` arm `final y?`), a null check that promotes, or a
non-nullable type that makes the case impossible (e.g. a page size stored as an `int`,
not `query.limit!`). The same goes for examples in docs and `llms.txt`, since people
copy them. In tests, prefer `isA<T>().having(...)` over `value!.field`, which fails more
clearly. This follows flyby's `docs/code_style/01_dart_foundation.md` ("Control flow and
expressions"), which is the style reference for this repo too.

## Architecture in one breath

`rules.dart` holds one-method capability interfaces, generic over the return type. `Collection`,
`CollectionGroup` and `Repository` are bundles of them (`ReadableQuery` is the read bundle).
Every query-shaped read builds a `FirefuelQuery` and lowers it through `FirefuelQuery.applyTo`,
the single place filters, order, cursors and limits are applied, via the `FirefuelQueryReads`
mixin. Every write serializes through `FirefuelCollection.encode`, which lowers `FieldUpdate`s
in `FieldUpdates.lower`. Repositories wrap each call in `guard`, which reports failures to
`Firefuel.observer`.

## Testing against real Firestore

The firefuel test files run on three backends. They get Firestore from `testFirestore()`
(`packages/firefuel/test/utils/test_backend.dart`), which is the fake unless a backend is installed.

| Command | Backend | Where |
|---|---|---|
| `flutter test` in packages/firefuel | fake_cloud_firestore | anywhere, CI `verify` |
| `tool/test_real_firestore.sh` | Firestore emulator (demo project, open rules) | macOS, CI `real-firestore` |
| `tool/test_live_firestore.sh` | live `firefuel-integration` project (Spark, free) | iOS simulator, on demand |

- Every test gets an empty database and a new Firebase app. A shared instance leaks between
  tests (check with `tool/test_real_firestore.sh --shared-instance`).
- A test that needs a second isolated Firestore uses `otherTestFirestore()` with
  `skip: skipWithoutOtherFirestore`. Emulator-only gaps use `skip: emulatorGap('...')`.
- Live runs delete **every document** in `firefuel-integration` before each test. Its rules
  admit one uid, `firefuel-integration-suite`, which the script signs in with a per-run custom
  token (needs the Service Account Token Creator role on the Admin SDK service account).
- New query shapes may need indexes in production: add them to
  `packages/firefuel_integration/firestore.indexes.json` and
  `firebase deploy --only firestore:indexes --project firefuel-integration`.

## Testing traps (all hit while building 0.5)

- fake_cloud_firestore applies query operations **in call order**. Cursors must be applied
  before limits: page cursors go through `applyTo(startAfterDocument:)`.
- It notifies listeners **per reference type**. Write through the typed `ref`, or streams
  built on `ref` never hear the write.
- It can't produce pending or cached metadata, can't go offline, and doesn't roll back a
  transaction whose handler throws. Test those mappings on mocks, and say what went unverified.
- equatable 3 doesn't compare `runtimeType`. Sealed variants lead their `props` with a type.
- The repository forwarding test stubs exact arguments. Add every new repository method to
  it; the Right/Left harness stubs `any()` and can't catch a dropped argument.

## Releasing

Nothing is published from a branch. The order is **firefuel_core first**, then firefuel, which
depends on it from pub. Changelogs follow the existing `## x.y.z` + `feat:/fix:` style.
