#!/usr/bin/env bash
# Railway GraphQL helpers. Requires: curl, jq, RAILWAY_TOKEN.
set -euo pipefail
shopt -s inherit_errexit 2>/dev/null || true

# shellcheck source=infra-curl.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-curl.sh"
# shellcheck source=infra-one.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/infra-one.sh"

RAILWAY_GQL_URL="${RAILWAY_GQL_URL:-https://backboard.railway.com/graphql/v2}"
RAILWAY_TARGET_PROJECT_NAME="${RAILWAY_TARGET_PROJECT_NAME:-ebwiki}"
RAILWAY_TARGET_SERVICE_NAME="${RAILWAY_TARGET_SERVICE_NAME:-ebwiki}"
RAILWAY_TARGET_DB_SERVICE_NAME="${RAILWAY_TARGET_DB_SERVICE_NAME:-Postgres}"
RAILWAY_TARGET_ENVIRONMENT_NAME="${RAILWAY_TARGET_ENVIRONMENT_NAME:-production}"
STAGING_EXPECTED_POSTGRES_DB="${STAGING_EXPECTED_POSTGRES_DB:-railway}"

infra_railway_gql_with_token() {
  local token="$1"
  local query="$2"
  local variables="${3:-}"
  local body
  [ -n "$variables" ] || variables='{}'
  [[ -n "$token" ]] || {
    echo "Railway token must be set." >&2
    return 1
  }
  body="$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')"
  infra_curl_post_json "$RAILWAY_GQL_URL" "$token" "$body"
}

infra_railway_gql() {
  local query="$1"
  local variables="${2:-}"
  : "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set}"
  infra_railway_gql_with_token "$RAILWAY_TOKEN" "$query" "$variables"
}

infra_railway_projects_payload() {
  local query='query { projects { edges { node { id name environments { edges { node { id name } } } services { edges { node { id name } } } } } } }'
  infra_railway_gql "$query"
}

infra_railway_find_project_service_env() {
  local payload project_id service_id environment_id

  payload="$(infra_railway_projects_payload)"
  project_id="$(echo "$payload" | jq -r --arg n "$RAILWAY_TARGET_PROJECT_NAME" \
    '.data.projects.edges[].node | select(.name == $n) | .id' | infra_one "Railway project named ${RAILWAY_TARGET_PROJECT_NAME}")" \
    || return 1
  service_id="$(echo "$payload" | jq -r --arg pn "$RAILWAY_TARGET_PROJECT_NAME" --arg sn "$RAILWAY_TARGET_SERVICE_NAME" \
    '.data.projects.edges[].node | select(.name == $pn) | .services.edges[].node | select(.name == $sn) | .id' \
    | infra_one "Railway service named ${RAILWAY_TARGET_SERVICE_NAME} in project ${RAILWAY_TARGET_PROJECT_NAME}")" \
    || return 1
  environment_id="$(echo "$payload" | jq -r --arg pn "$RAILWAY_TARGET_PROJECT_NAME" --arg en "$RAILWAY_TARGET_ENVIRONMENT_NAME" \
    '.data.projects.edges[].node | select(.name == $pn) | .environments.edges[].node | select(.name == $en) | .id' \
    | infra_one "Railway environment named ${RAILWAY_TARGET_ENVIRONMENT_NAME} in project ${RAILWAY_TARGET_PROJECT_NAME}")" \
    || return 1

  printf '%s %s %s\n' "$project_id" "$service_id" "$environment_id"
}

infra_railway_find_postgres_service_id() {
  local payload db_service_id

  payload="$(infra_railway_projects_payload)"
  db_service_id="$(echo "$payload" | jq -r --arg pn "$RAILWAY_TARGET_PROJECT_NAME" --arg dn "$RAILWAY_TARGET_DB_SERVICE_NAME" \
    '.data.projects.edges[].node | select(.name == $pn) | .services.edges[].node | select(.name == $dn) | .id' \
    | infra_one "Railway Postgres service named ${RAILWAY_TARGET_DB_SERVICE_NAME} in project ${RAILWAY_TARGET_PROJECT_NAME}")" \
    || return 1
  printf '%s' "$db_service_id"
}

# Railway CLI reads RAILWAY_API_TOKEN for account/workspace tokens. Doppler exposes the
# same value as RAILWAY_TOKEN for GraphQL helpers; unset it before invoking the CLI.
infra_railway_ssh() {
  : "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set}"
  env -u RAILWAY_TOKEN RAILWAY_API_TOKEN="$RAILWAY_TOKEN" railway ssh "$@"
}

infra_railway_public_domain() {
  local project_id="$1"
  local environment_id="$2"
  local service_id="$3"
  local query='query($projectId: String!, $environmentId: String!, $serviceId: String!) { domains(projectId: $projectId, environmentId: $environmentId, serviceId: $serviceId) { serviceDomains { domain } } }'
  local vars domain

  vars="$(jq -n --arg p "$project_id" --arg e "$environment_id" --arg s "$service_id" \
    '{projectId: $p, environmentId: $e, serviceId: $s}')"
  domain="$(infra_railway_gql "$query" "$vars" \
    | jq -r '.data.domains.serviceDomains[].domain' \
    | infra_one "Railway public service domain for service ${service_id}")" \
    || return 1
  printf '%s' "$domain"
}

# Remote script for `railway ssh ... bash -s` on the Postgres service (postgres:17 image).
infra_railway_remote_postgres_pg_dump_shell() {
  cat <<'REMOTE'
set -euo pipefail
: "${POSTGRES_USER:?POSTGRES_USER must be set in the Postgres service}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD must be set in the Postgres service}"
: "${POSTGRES_DB:?POSTGRES_DB must be set in the Postgres service}"
export PGPASSWORD="$POSTGRES_PASSWORD"
exec pg_dump -Fc --no-owner --no-acl -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB"
REMOTE
}

# Remote script for restore: stdin is the dump; all-or-nothing pg_restore.
infra_railway_remote_postgres_pg_restore_shell() {
  local expected_db="$1"
  cat <<REMOTE
set -euo pipefail
: "\${POSTGRES_USER:?POSTGRES_USER must be set in the Postgres service}"
: "\${POSTGRES_PASSWORD:?POSTGRES_PASSWORD must be set in the Postgres service}"
: "\${POSTGRES_DB:?POSTGRES_DB must be set in the Postgres service}"
if [ "\$POSTGRES_DB" != "${expected_db}" ]; then
  echo "Refusing restore: POSTGRES_DB=\$POSTGRES_DB (expected ${expected_db})." >&2
  exit 1
fi
export PGPASSWORD="\$POSTGRES_PASSWORD"
exec pg_restore --clean --if-exists --no-owner --no-acl --single-transaction --exit-on-error \
  -h localhost -U "\$POSTGRES_USER" -d "\$POSTGRES_DB"
REMOTE
}
