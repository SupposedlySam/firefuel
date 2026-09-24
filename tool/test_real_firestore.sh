#!/usr/bin/env bash
# Runs firefuel's test files against the Firestore emulator (see
# packages/firefuel_integration). Needs the Firebase CLI, Java 21+, and a Mac:
# cloud_firestore has no Linux desktop support.
#
#   tool/test_real_firestore.sh
#   tool/test_real_firestore.sh --shared-instance   # one Firestore for all tests,
#                                                   # as live runs use
set -euo pipefail

defines=()
[[ "${1:-}" == "--shared-instance" ]] && defines+=(--dart-define=FIREFUEL_SHARED_INSTANCE=true)

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root/packages/firefuel_integration"

firebase emulators:exec \
  --config "$root/firebase.emulator.json" \
  --only firestore \
  --project demo-firefuel \
  "flutter test integration_test/firefuel_suite_test.dart -d macos ${defines[*]:-}"
