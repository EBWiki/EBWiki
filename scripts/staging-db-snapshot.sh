#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-railway.sh
source "$ROOT/scripts/lib/infra-railway.sh"

: "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set (Doppler ebwiki/infra)}"
: "${R2_BUCKET_NAME:?R2_BUCKET_NAME must be set (Doppler ebwiki/infra)}"
: "${R2_S3_ENDPOINT:?R2_S3_ENDPOINT must be set (Doppler ebwiki/infra)}"
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID must be set (Doppler ebwiki/infra)}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY must be set (Doppler ebwiki/infra)}"

command -v aws >/dev/null 2>&1 || { echo "aws CLI is required for R2 upload."; exit 1; }

ids="$(infra_railway_find_project_service_env)"
read -r project_id service_id environment_id <<<"$ids"

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
object_key="staging/db-snapshots/${timestamp}.dump"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-auto}"
export INFRA_SNAPSHOT_OBJECT_KEY="$object_key"

infra_snapshot_stream_to_r2() {
  if [ -n "${INFRA_SNAPSHOT_PIPE_CMD:-}" ]; then
    # Test hook: command must write dump bytes to stdout (e.g. printf or mock pg_dump).
    bash -c "$INFRA_SNAPSHOT_PIPE_CMD"
    return
  fi

  command -v railway >/dev/null 2>&1 || {
    echo "Railway CLI is required. Install from https://docs.railway.com/cli (pg_dump runs inside the app service via railway ssh)." >&2
    exit 1
  }

  # pg_dump runs inside the deployed ebwiki service (private network to Postgres). stdout streams to R2.
  infra_railway_remote_pg_dump_shell | railway ssh \
    --project "$project_id" \
    --environment "$environment_id" \
    --service "$service_id" \
    -- bash -s
}

infra_snapshot_stream_to_r2 | aws s3 cp - "s3://${R2_BUCKET_NAME}/${object_key}" \
  --endpoint-url "$R2_S3_ENDPOINT" \
  --only-show-errors

echo "Uploaded staging Postgres snapshot to s3://${R2_BUCKET_NAME}/${object_key}"
