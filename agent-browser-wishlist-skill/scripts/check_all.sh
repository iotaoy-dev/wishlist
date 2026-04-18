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

CSV_FILE="${1:-wishlist.csv}"

if [[ ! -f "$CSV_FILE" ]]; then
  echo "CSV file not found: $CSV_FILE"
  exit 1
fi

FAILED=0

# Skip header
TAIL_CMD=(tail -n +2 "$CSV_FILE")
while IFS=, read -r item_id target_url login_url platform notes; do
  [[ -z "${item_id:-}" ]] && continue
  echo "=============================="
  echo "Running check for: $item_id ($platform)"
  if ! bash scripts/check_item.sh "$item_id" "$target_url" "$login_url"; then
    FAILED=$((FAILED+1))
  fi
  echo
  sleep 2
done < <("${TAIL_CMD[@]}")

echo "Completed. Failed items: $FAILED"
exit 0
