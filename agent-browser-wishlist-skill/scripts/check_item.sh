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

mkdir -p "$OUTPUT_DIR" "$STATE_DIR"

ITEM_ID="${1:?Usage: bash scripts/check_item.sh <item_id> <target_url> <login_url>}"
TARGET_URL="${2:?Usage: bash scripts/check_item.sh <item_id> <target_url> <login_url>}"
LOGIN_URL="${3:?Usage: bash scripts/check_item.sh <item_id> <target_url> <login_url>}"

STAMP="$(date +%Y%m%d-%H%M%S)"
SCREENSHOT="$OUTPUT_DIR/${ITEM_ID}-${STAMP}.png"
LOGFILE="$OUTPUT_DIR/${ITEM_ID}-${STAMP}.log"

exec > >(tee -a "$LOGFILE") 2>&1

echo "[$(date)] Checking item: $ITEM_ID"
echo "Target URL: $TARGET_URL"

after_fail_cleanup() {
  echo "Cleaning up browser session..."
  agent-browser close >/dev/null 2>&1 || true
}
trap after_fail_cleanup EXIT

agent-browser --profile "$AB_PROFILE" open "$TARGET_URL"
agent-browser wait --load networkidle || true

if [[ -n "${AB_EXTRA_WAIT_MS:-}" ]]; then
  agent-browser wait "$AB_EXTRA_WAIT_MS" || true
fi

CURRENT_URL="$(agent-browser get url || true)"
TITLE="$(agent-browser get title || true)"

echo "Current URL: $CURRENT_URL"
echo "Page title: $TITLE"

# Evidence first
agent-browser screenshot "$SCREENSHOT" || true

echo "$CURRENT_URL" | grep -Ei "$(printf '%s' "$LOGIN_URL" | sed 's/[^^]/[&]/g; s/\^/\\^/g')" >/dev/null 2>&1 && LOGIN_REQUIRED=1 || LOGIN_REQUIRED=0

# Fallback: common login words in URL or title
if [[ "$LOGIN_REQUIRED" -eq 0 ]]; then
  if echo "$CURRENT_URL $TITLE" | grep -Eiq 'login|signin|sign in|passport|扫码登录|请登录|登录'; then
    LOGIN_REQUIRED=1
  fi
fi

if [[ "$LOGIN_REQUIRED" -eq 1 ]]; then
  echo "Login appears to be required."
  osascript scripts/send_mail.applescript \
    "$ALERT_TO" \
    "$ALERT_SUBJECT_PREFIX Login expired for $ITEM_ID" \
    "Wishlist Agent detected a login problem.\n\nItem: $ITEM_ID\nTarget: $TARGET_URL\nCurrent URL: $CURRENT_URL\nSuggested login URL: $LOGIN_URL\nScreenshot: $SCREENSHOT\nLog: $LOGFILE\n\nOpen the login URL in the dedicated profile, complete auth, then rerun the task." \
    "$SCREENSHOT" || true

  exit 20
fi

echo "Session still looks valid."
echo "MVP currently stops at auth validation + evidence capture."
echo "Next step: add price extraction logic here."
exit 0
