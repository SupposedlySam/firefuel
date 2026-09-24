# Toolchain, workspace and hygiene

## Metadata
- **Type:** Chore
- **Appetite:** 1 day
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** raises the SDK floor only

## Problem
The repo was last tuned for Flutter 3.32.8 / Dart 3.8. Three packages resolve separately,
so changing `firefuel_core` and `firefuel` together means publishing core first. There is
no CI: nothing runs analyze or the tests on a push, so "the suite is green" has only ever
meant "green on somebody's machine". `firefuel_env` is an unpublished Very Good CLI stub
with no code. `universal_io` is a dependency of both published packages, used only by a
`print` in `Failure`'s constructor and a test-path helper that lives in `lib/`.

## Evidence
- `flutter pub outdated` (2026-09-23): cloud_firestore 6.3.0 → 6.10.0, very_good_analysis
  9 → 11, equatable 2.0.8 → 2.1.0 (`EquatableMixin` deprecated in favour of `Equatable` as a
  mixin).
- `.github/` has no `workflows/`.
- flyby runs Flutter 3.47.5 / Dart 3.13.4 with `sdk: ^3.11.0`.

## Criteria
### Must have
- Flutter 3.47.5 pinned via `.fvmrc`; `sdk: ^3.10.0` (dot shorthands, null-aware elements,
  pub workspaces) and `flutter: '>=3.38.0'`.
- A root pub **workspace** (`packages/firefuel`, `packages/firefuel/example`,
  `packages/firefuel_core`), one lockfile, one `dart analyze` for the lot.
- Every dependency at its latest resolvable major; analyzer clean with very_good_analysis 11.
- `universal_io` removed from both published packages.
- CI: analyze + format check + test on pull requests and pushes to branches. It must not deploy.
- `firefuel_env` deleted.
### Nice to have
- `CLAUDE.md` and `llms.txt` at the root so an agent can get oriented without rereading the source.

## Boundaries
### Out of scope
- Replacing derry/mason. They still work; changing task runners is churn for no consumer.
- Publishing anything.

## How it fails
- The workspace changes how `firefuel` resolves `firefuel_core`. A published `firefuel` still
  depends on `firefuel_core: ^x.y.z` from pub, so core has to be published first. Record that
  in the release notes.

## Outcome (2026-09-23)
All must-haves shipped: `0af13de`, `94cfc07` and `09d1c91`. `CLAUDE.md` came later.
**CI verified (2026-09-24):** its first run, on the push of `chore/upgrade-2026` (GitHub Actions run 36017079955), passed every step: fvm setup, format, analyze, the three test suites and the publish dry run. The Pages deploy did not trigger, as intended.
