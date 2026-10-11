#!/usr/bin/env bash
# Restore a pg_dump from R2 into staging Postgres via railway ssh (private network).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/infra-railway.sh
source "$ROOT/scripts/lib/infra-railway.sh"

object_key="${1:?Usage: staging-db-restore.sh staging/db-snapshots/<timestamp>.dump}"

: "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set (Doppler ebwiki/infra)}"
: "${R2_BUCKET_NAME:?R2_BUCKET_NAME must be set (Doppler ebwiki/infra)}"
: "${R2_S3_ENDPOINT:?R2_S3_ENDPOINT must be set (Doppler ebwiki/infra)}"
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID must be set (Doppler ebwiki/infra)}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY must be set (Doppler ebwiki/infra)}"

command -v aws >/dev/null 2>&1 || { echo "aws CLI is required."; exit 1; }
command -v railway >/dev/null 2>&1 || { echo "Railway CLI is required."; exit 1; }

ids="$(infra_railway_find_project_service_env)" || exit 1
read -r project_id _service_id environment_id <<<"$ids"
db_service_id="$(infra_railway_find_postgres_service_id)" || exit 1

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-auto}"

echo "About to OVERWRITE Postgres in Railway project ${RAILWAY_TARGET_PROJECT_NAME} (${project_id}), environment ${RAILWAY_TARGET_ENVIRONMENT_NAME}, from ${object_key}." >&2
[ "${CONFIRM_RESTORE:-}" = "$project_id" ] || {
  echo "Set CONFIRM_RESTORE=${project_id} to proceed." >&2
  exit 1
}

aws s3api head-object --bucket "$R2_BUCKET_NAME" --key "$object_key" --endpoint-url "$R2_S3_ENDPOINT" >/dev/null

restore_script="$(infra_railway_remote_postgres_pg_restore_shell "$STAGING_EXPECTED_POSTGRES_DB")"
aws s3 cp "s3://${R2_BUCKET_NAME}/${object_key}" - --endpoint-url "$R2_S3_ENDPOINT" --only-show-errors \
  | railway ssh \
    --project "$project_id" \
    --environment "$environment_id" \
    --service "$db_service_id" \
    -- sh -ec "$restore_script"

echo "Restored ${object_key} into staging Postgres (${STAGING_EXPECTED_POSTGRES_DB})."
