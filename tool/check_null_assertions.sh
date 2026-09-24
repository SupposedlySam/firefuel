#!/usr/bin/env bash
# Fails if the published libraries use the null assertion operator (`!`).
#
# A `!` is a runtime crash waiting for the one caller the author didn't
# picture. Use a pattern (`if (x case final y?)`, `switch` with `final y?`),
# a null check that promotes, or a non-nullable type instead. The rule and
# its reasons: CLAUDE.md, "Null safety".
#
# The match is textual: `name!`, `call()!`, `list[0]!` followed by `.`, `;`,
# `,`, `)`, `]`, a space or end of line. It skips `!=` and comment lines.
set -euo pipefail
cd "$(dirname "$0")/.."

hits="$(grep -rnE '[])A-Za-z0-9_]!([].;,) []|$)' packages/firefuel/lib packages/firefuel_core/lib \
  | grep -v '!=' | grep -vE ':[0-9]+:\s*//' || true)"

if [[ -n "$hits" ]]; then
  echo "Null assertions (!) in library code:" >&2
  echo "$hits" >&2
  exit 1
fi
echo "No null assertions in packages/firefuel/lib or packages/firefuel_core/lib."
