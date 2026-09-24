#!/usr/bin/env bash
# Runs firefuel's test files against the live `firefuel-integration` Firebase
# project on an iOS simulator. On macOS, Firebase Auth needs a provisioned
# keychain entitlement, so macOS runs use the emulator instead
# (tool/test_real_firestore.sh).
#
# Every document in that project is deleted before each test. Never point this
# at a project with data you want to keep.
#
# Needs: gcloud signed in with access to the project, an iOS simulator, and
# ~/.config/firefuel/live.json holding the test user:
#   {"email": "...", "password": "..."}
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
credentials="${FIREFUEL_LIVE_CREDENTIALS:-$HOME/.config/firefuel/live.json}"
simulator="${FIREFUEL_SIMULATOR:-iPhone 16}"

[[ -f "$credentials" ]] || { echo "missing $credentials" >&2; exit 2; }

udid="$(xcrun simctl list devices available -j | python3 -c "
import json, sys
name = sys.argv[1]
for runtime in json.load(sys.stdin)['devices'].values():
    for device in runtime:
        if device['name'] == name:
            print(device['udid']); sys.exit()
" "$simulator")"
[[ -n "$udid" ]] || { echo "no simulator named '$simulator'" >&2; exit 2; }
xcrun simctl boot "$udid" 2>/dev/null || true

# The defines hold a password and an OAuth token: write them outside the repo
# and remove them on exit.
defines="$(mktemp -t firefuel-live)"
trap 'rm -f "$defines"' EXIT
python3 - "$credentials" "$(gcloud auth print-access-token)" > "$defines" <<'PY'
import json, sys
creds = json.load(open(sys.argv[1]))
print(json.dumps({
    "FIREFUEL_BACKEND": "live",
    "FIREFUEL_LIVE_EMAIL": creds["email"],
    "FIREFUEL_LIVE_PASSWORD": creds["password"],
    "FIREFUEL_LIVE_TOKEN": sys.argv[2],
}))
PY

cd "$root/packages/firefuel_integration"
flutter test integration_test/firefuel_suite_test.dart \
  -d "$udid" --dart-define-from-file="$defines"
