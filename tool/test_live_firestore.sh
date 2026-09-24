#!/usr/bin/env bash
# Runs firefuel's test files against the live `firefuel-integration` Firebase
# project on an iOS simulator. On macOS, Firebase Auth needs a provisioned
# keychain entitlement, so macOS runs use the emulator instead
# (tool/test_real_firestore.sh).
#
# Every document in that project is deleted before each test. Never point this
# at a project with data you want to keep.
#
# Needs: gcloud signed in as a user with the Service Account Token Creator
# role on the project's Firebase Admin SDK service account (to mint the custom
# token the suite signs in with), and an iOS simulator.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
project=firefuel-integration
service_account="firebase-adminsdk-fbsvc@$project.iam.gserviceaccount.com"
simulator="${FIREFUEL_SIMULATOR:-iPhone 16}"

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

# Tokens are written outside the repo and removed on exit.
scratch="$(mktemp -d -t firefuel-live)"
trap 'rm -rf "$scratch"' EXIT

# A Firebase custom token for the uid the rules admit, valid for an hour.
now="$(date +%s)"
cat > "$scratch/claims.json" <<CLAIMS
{"iss": "$service_account", "sub": "$service_account",
 "aud": "https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit",
 "iat": $now, "exp": $((now + 3600)), "uid": "firefuel-integration-suite"}
CLAIMS
gcloud iam service-accounts sign-jwt "$scratch/claims.json" "$scratch/custom.jwt" \
  --iam-account="$service_account" --project="$project" >/dev/null

python3 - "$scratch/custom.jwt" "$(gcloud auth print-access-token)" > "$scratch/defines.json" <<'PY'
import json, sys
print(json.dumps({
    "FIREFUEL_BACKEND": "live",
    "FIREFUEL_LIVE_CUSTOM_TOKEN": open(sys.argv[1]).read().strip(),
    "FIREFUEL_LIVE_TOKEN": sys.argv[2],
}))
PY
defines="$scratch/defines.json"

cd "$root/packages/firefuel_integration"
# Every write waits on the network; a 501-write batch test needs far more than
# the default 30-second test timeout.
flutter test integration_test/firefuel_suite_test.dart \
  -d "$udid" --timeout=300s --dart-define-from-file="$defines"
