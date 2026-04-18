#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
else
  # shellcheck disable=SC1091
  source ./config.example.env
fi

mkdir -p "$AB_PROFILE" "$OUTPUT_DIR" "$STATE_DIR"

LOGIN_URL="${1:-}"
if [[ -z "$LOGIN_URL" ]]; then
  echo "Usage: bash scripts/bootstrap_login.sh <login_url_or_site_url>"
  echo "Example: bash scripts/bootstrap_login.sh https://passport.jd.com/new/login.aspx"
  exit 1
fi

echo "Opening dedicated profile: $AB_PROFILE"
echo "Complete login manually in the browser window, then press Enter here."

agent-browser --profile "$AB_PROFILE" --headed open "$LOGIN_URL"
agent-browser wait --load networkidle || true

read -r -p "Press Enter after login is complete..."

STAMP="$(date +%Y%m%d-%H%M%S)"
STATE_FILE="$STATE_DIR/manual-auth-$STAMP.json"
agent-browser state save "$STATE_FILE" || true
CURRENT_URL="$(agent-browser get url || true)"

echo "Current URL: $CURRENT_URL"
echo "Saved a state snapshot to: $STATE_FILE"
echo "Bootstrap complete."
