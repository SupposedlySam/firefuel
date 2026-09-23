# FirefuelObserver and quieter failures

## Metadata
- **Type:** Feature
- **Appetite:** 1 day
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** yes (stdout printing removed from the `FirefuelFailure` constructor)

## Problem
Every `FirefuelFailure` prints itself to stdout **in its constructor**. That's a side effect
inside a value, it's why `firefuel_core` depends on `universal_io`, and apps can't turn it
off. `guard` also prints `FormatException`s. Meanwhile issue #18 asks for a BlocObserver-style
hook to see which database calls are being made.

## Shaping
- `FirefuelObserver` with `onFailure(Failure)` and optionally `onOperation(name, path)`,
  set through `Firefuel.initialize(observer:)`. The default observer logs through
  `dart:developer` `log`, not `print`, so it reaches DevTools and stays quiet in release.
- `FirefuelFailure` constructs silently. `guard`/`guardStream` report to the observer.

## Outcome (2026-09-23)
- `FirefuelObserver.onFailure` is set through `Firefuel.initialize(observer:)`. The default logs to
  `dart:developer`; `SilentFirefuelObserver` ignores everything.
- `guard` and `guardStream` report through `FirefuelFetchMixin.report`, which is public so apps'
  own catch blocks can report the same way. The `print` of `FormatException`s is gone. The
  constructor `print` went in 01.
- **Issue #18 is only partly met.** Failures are observable, but there's no `onOperation`
  hook for every database call. Hooking every method adds a call to each of about 40 methods
  on three layers, and nobody has asked for it since 2021. Revisit if a consumer does.
