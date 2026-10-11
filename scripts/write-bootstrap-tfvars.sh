#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-cloudflare.sh
source "$ROOT/scripts/lib/infra-cloudflare.sh"

OUT="${1:-$ROOT/infra/bootstrap/terraform.tfvars}"
ZONE_NAME="${CLOUDFLARE_ZONE_NAME:-ebwiki.org}"

: "${CLOUDFLARE_ZONE_READ_API_TOKEN:?Set CLOUDFLARE_ZONE_READ_API_TOKEN (grandkru/prd) for zone lookup}"

command -v curl >/dev/null 2>&1 || { echo "curl is required."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required."; exit 1; }

zone_json="$(infra_cf_zone_for_name "$ZONE_NAME" "$CLOUDFLARE_ZONE_READ_API_TOKEN")"
zone_id="$(echo "$zone_json" | jq -r '.id')"
account_id="$(echo "$zone_json" | jq -r '.account.id')"

mkdir -p "$(dirname "$OUT")"
cat >"$OUT" <<EOF
cloudflare_account_id = "${account_id}"
cloudflare_zone_id    = "${zone_id}"
EOF

echo "Wrote ${OUT} (zone ${ZONE_NAME})."
