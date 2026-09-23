# Project management

[Shape Up](https://basecamp.com/shapeup) pitches for firefuel. Each pitch names a problem,
an appetite, a rough shape and its boundaries — enough to commit to a fixed-time bet
without over-specifying.

## North star

> Firestore, the easy way: **simple, intuitive, consistent.** A typed, testable data layer
> where every Firestore capability a Flutter app needs is reachable *through* firefuel, so
> nobody has to reach around it.

Two measures keep that honest:

- **Reach-arounds.** Every place a consumer drops to raw `cloud_firestore` is a gap in
  firefuel. The primary consumer is flyby (`~/dev/flyby_workspace/flyby`); its reach-arounds
  are the backlog, recorded per pitch.
- **Pass-through debt.** Every public `cloud_firestore` capability is either exposed, or
  deliberately declined with the reason written down (see [`pass-through.md`](pass-through.md)).

## Workflow

```
project_management/
├── pitches/   # shaped, not yet committed — "if we wanted to do this..."
├── bet/       # currently being built
└── done/      # shipped / question answered
```

The folder a file lives in IS its status. `Status:` in each pitch mirrors it.

- `pitches/` → `bet/`: when work starts. `git mv`, set `Status: Bet (started YYYY-MM-DD)`.
- `bet/` → `done/`: when the must-haves ship. Same `git mv`.
- **Dropping a pitch:** move it to `dropped/` with a *Why dropped* note — a rejected idea kept
  next to its reason stops the next person re-proposing it.

## Pitch conventions

- **File naming:** `NN-kebab-case-name.md`. Numbers stay stable across folder moves.
- **Appetite** is a fixed budget, not an estimate.
- **Open Questions** should empty out as the pitch is shaped.

## Pitch template

```markdown
# <Title>

## Metadata
- **Type:** Feature / Fix / Improvement / Infrastructure / Chore
- **Appetite:** 1 day / 3 days / 2 weeks
- **Status:** Pitch / Bet / Done
- **Created:** YYYY-MM-DD
- **Breaking:** yes / no

## Problem
## Evidence
Consumer reach-arounds, issues, measurements.
## Criteria
### Must have
### Nice to have
## Boundaries
### In scope
### Out of scope (rabbit holes to avoid)
## Shaping
## How it fails
## Open Questions
```

## Pitches at a glance

Build order and reasons: [DESIGN.md](DESIGN.md) D1. Consumer demand is flyby-owner's answer
from 2026-09-23.

| Order | # | Title | Type | flyby demand |
|---|---|---|---|---|
| 1 | 01 | [Toolchain, workspace, hygiene](pitches/01-toolchain-and-workspace.md) | Chore | — |
| 2 | 02 | [Correctness fixes](pitches/02-correctness-fixes.md) | Fix | direction bug (latent) |
| 3 | 10 | [Own the Either](pitches/10-either-without-dartz.md) | Improvement | ok, keep names |
| 4 | 12 | [The query is a value](pitches/12-query-layer.md) | Infrastructure | enables 05/06 |
| 5 | 03 | [Instance resolution](pitches/03-firestore-instance-resolution.md) | Feature | low |
| 6 | 04 | [Server values and multi-field updates](pitches/04-write-values.md) | Feature | **yes** |
| 7 | 07 | [Transactions](pitches/07-transactions.md) | Feature | no |
| 8 | 06 | [Collection groups](pitches/06-collection-groups.md) | Feature | **yes** |
| 9 | 05 | [Snapshot metadata](pitches/05-snapshot-metadata.md) | Feature | **highest** |
| 10 | 08 | [Query power](pitches/08-query-power.md) | Feature | no |
| 11 | 09 | [Observer, quieter failures](pitches/09-observer-and-failures.md) | Feature | — |
| 12 | 13 | [Offline writes](pitches/13-offline-writes.md) | Feature | — |
| 13 | 11 | [Docs and site](pitches/11-docs-site-refresh.md) | Chore | — |

Capability coverage: [pass-through.md](pass-through.md).
