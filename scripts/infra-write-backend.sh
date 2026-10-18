#!/usr/bin/env bash
# Write an OpenTofu S3/R2 backend config from Doppler ebwiki/infra secrets (already in env).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND_FILE="${1:-$ROOT/infra/staging/backend.hcl}"
STATE_KEY="${2:-staging/terraform.tfstate}"

: "${R2_BUCKET_NAME:?R2_BUCKET_NAME must be set (Doppler ebwiki/infra)}"
: "${R2_S3_ENDPOINT:?R2_S3_ENDPOINT must be set (Doppler ebwiki/infra)}"

mkdir -p "$(dirname "$BACKEND_FILE")"
cat >"$BACKEND_FILE" <<EOF
bucket       = "${R2_BUCKET_NAME}"
key          = "${STATE_KEY}"
region       = "auto"
endpoints    = { s3 = "${R2_S3_ENDPOINT}" }
use_lockfile = true

skip_credentials_validation = true
skip_metadata_api_check     = true
skip_region_validation      = true
skip_requesting_account_id  = true
skip_s3_checksum            = true
use_path_style              = true
EOF

echo "Wrote ${BACKEND_FILE} (key=${STATE_KEY})"
