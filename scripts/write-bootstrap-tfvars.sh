#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-cloudflare.sh
source "$ROOT/scripts/lib/infra-cloudflare.sh"

OUT="${1:-$ROOT/infra/bootstrap/terraform.tfvars}"
EBWIKI_ZONE_NAME="${CLOUDFLARE_ZONE_NAME:-ebwiki.org}"
GRANDKRU_ZONE_NAME="${CLOUDFLARE_GRANDKRU_ZONE_NAME:-grandkru.com}"

: "${CLOUDFLARE_ZONE_READ_API_TOKEN:?Set CLOUDFLARE_ZONE_READ_API_TOKEN (grandkru/prd) for zone lookup}"

command -v curl >/dev/null 2>&1 || { echo "curl is required."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required."; exit 1; }

ebwiki_zone_json="$(infra_cf_zone_for_name "$EBWIKI_ZONE_NAME" "$CLOUDFLARE_ZONE_READ_API_TOKEN")"
ebwiki_zone_id="$(echo "$ebwiki_zone_json" | jq -r '.id')"
account_id="$(echo "$ebwiki_zone_json" | jq -r '.account.id')"

grandkru_zone_json="$(infra_cf_zone_for_name "$GRANDKRU_ZONE_NAME" "$CLOUDFLARE_ZONE_READ_API_TOKEN")"
grandkru_zone_id="$(echo "$grandkru_zone_json" | jq -r '.id')"

mkdir -p "$(dirname "$OUT")"
cat >"$OUT" <<EOF
cloudflare_account_id         = "${account_id}"
cloudflare_zone_id            = "${ebwiki_zone_id}"
cloudflare_grandkru_zone_id   = "${grandkru_zone_id}"
EOF

echo "Wrote ${OUT} (zones ${EBWIKI_ZONE_NAME}, ${GRANDKRU_ZONE_NAME})."
