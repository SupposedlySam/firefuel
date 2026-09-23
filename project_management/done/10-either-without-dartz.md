# Own the Either

## Metadata
- **Type:** Improvement
- **Appetite:** 2 days
- **Status:** Done (2026-09-23)
- **Created:** 2026-09-23
- **Breaking:** possibly, for anyone using dartz methods beyond the core ones

## Problem
`dartz` 0.10.1 is from 2021 and unmaintained. Every firefuel user depends on it transitively,
and firefuel re-exports its `Either`. Dart 3 sealed classes and patterns make a small
`Either` natural (`switch (result) { Left(:final value) => ..., Right(:final value) => ... }`),
which dartz cannot offer.

## Evidence
flyby audit: flyby gets `Either` only through firefuel's re-export. It has 3 direct dartz
imports and uses `fold`, `isLeft`/`isRight`, `Left`/`Right` and the `getRight*` extensions.

## Shaping
- `sealed class Either<L, R>` with `final class Left` and `Right`, carrying `fold`, `map`,
  `leftMap`, `flatMap`, `getOrElse`, `swap`, `isLeft`, `isRight`, and the lowercase
  `left()`/`right()` constructors that firefuel already re-exports.
- It lives in `firefuel_core`, beside `Failure`.

## Open Questions
- Is this worth a breaking change *now*, or should it ship as a deprecation-compatible layer
  first? Architecture review decides.

## flyby's answer (2026-09-23)
Fine to replace. flyby uses `Either`, `Left`, `Right`, `fold`, `map`, `isLeft`, `isRight`,
`getOrElse` (8), `getRight` (17), `getRightOrElseNull` (4), `getLeft` (1) and
`getLeftOrElseNull` (2). It doesn't use `flatMap`/`bind`/`leftMap`/`swap`. After flyby commit
`8410c459`, only 2 test files import dartz directly.
