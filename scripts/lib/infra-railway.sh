#!/usr/bin/env bash
# Railway GraphQL helpers. Requires: curl, jq, RAILWAY_TOKEN.
set -euo pipefail

RAILWAY_GQL_URL="${RAILWAY_GQL_URL:-https://backboard.railway.com/graphql/v2}"
RAILWAY_TARGET_PROJECT_NAME="${RAILWAY_TARGET_PROJECT_NAME:-ebwiki}"
RAILWAY_TARGET_SERVICE_NAME="${RAILWAY_TARGET_SERVICE_NAME:-ebwiki}"
RAILWAY_TARGET_ENVIRONMENT_NAME="${RAILWAY_TARGET_ENVIRONMENT_NAME:-production}"

infra_railway_gql() {
  local query="$1"
  local variables="${2:-{}}"
  : "${RAILWAY_TOKEN:?RAILWAY_TOKEN must be set}"
  curl -fsS "$RAILWAY_GQL_URL" \
    -H "Authorization: Bearer ${RAILWAY_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')"
}

infra_railway_find_project_service_env() {
  local query='query { projects { edges { node { id name environments { edges { node { id name } } } services { edges { node { id name } } } } } } }'
  local payload project_id service_id environment_id

  payload="$(infra_railway_gql "$query")"
  project_id="$(echo "$payload" | jq -r --arg n "$RAILWAY_TARGET_PROJECT_NAME" \
    '.data.projects.edges[].node | select(.name == $n) | .id' | head -1)"
  service_id="$(echo "$payload" | jq -r --arg pn "$RAILWAY_TARGET_PROJECT_NAME" --arg sn "$RAILWAY_TARGET_SERVICE_NAME" \
    '.data.projects.edges[].node | select(.name == $pn) | .services.edges[].node | select(.name == $sn) | .id' | head -1)"
  environment_id="$(echo "$payload" | jq -r --arg pn "$RAILWAY_TARGET_PROJECT_NAME" --arg en "$RAILWAY_TARGET_ENVIRONMENT_NAME" \
    '.data.projects.edges[].node | select(.name == $pn) | .environments.edges[].node | select(.name == $en) | .id' | head -1)"

  if [ -z "$project_id" ] || [ -z "$service_id" ] || [ -z "$environment_id" ]; then
    echo "Could not find Railway project/service/environment (${RAILWAY_TARGET_PROJECT_NAME}/${RAILWAY_TARGET_SERVICE_NAME}/${RAILWAY_TARGET_ENVIRONMENT_NAME})." >&2
    return 1
  fi

  printf '%s %s %s\n' "$project_id" "$service_id" "$environment_id"
}

infra_railway_public_domain() {
  local project_id="$1"
  local environment_id="$2"
  local service_id="$3"
  local query='query($projectId: String!, $environmentId: String!, $serviceId: String!) { domains(projectId: $projectId, environmentId: $environmentId, serviceId: $serviceId) }'
  local vars domain

  vars="$(jq -n --arg p "$project_id" --arg e "$environment_id" --arg s "$service_id" \
    '{projectId: $p, environmentId: $e, serviceId: $s}')"
  domain="$(infra_railway_gql "$query" "$vars" \
    | jq -r '.data.domains.serviceDomains[0].domain // empty')"
  if [ -z "$domain" ]; then
    domain="$(infra_railway_gql "$query" "$vars" | jq -r '.data.domains.serviceDomains[].domain' | head -1)"
  fi
  if [ -z "$domain" ]; then
    echo "No Railway service domain found for service ${service_id}." >&2
    return 1
  fi
  printf '%s' "$domain"
}

infra_railway_database_url() {
  local project_id="$1"
  local environment_id="$2"
  local service_id="$3"
  local query='query($projectId: String!, $environmentId: String!, $serviceId: String!) { variables(projectId: $projectId, environmentId: $environmentId, serviceId: $serviceId) }'
  local vars url shared_query shared_url

  vars="$(jq -n --arg p "$project_id" --arg e "$environment_id" --arg s "$service_id" \
    '{projectId: $p, environmentId: $e, serviceId: $s}')"
  url="$(infra_railway_gql "$query" "$vars" | jq -r '.data.variables.DATABASE_URL // empty')"

  if [ -z "$url" ] || [[ "$url" == *'${{'* ]]; then
    shared_query='query($projectId: String!, $environmentId: String!) { variables(projectId: $projectId, environmentId: $environmentId) }'
    vars="$(jq -n --arg p "$project_id" --arg e "$environment_id" '{projectId: $p, environmentId: $e}')"
    shared_url="$(infra_railway_gql "$shared_query" "$vars" | jq -r '.data.variables.DATABASE_URL // empty')"
    if [ -n "$shared_url" ] && [[ "$shared_url" != *'${{'* ]]; then
      url="$shared_url"
    fi
  fi

  if [ -z "$url" ] || [[ "$url" == *'${{'* ]]; then
    if command -v doppler >/dev/null 2>&1; then
      url="$(doppler secrets get DATABASE_URL --project ebwiki --config stg --plain 2>/dev/null || true)"
    fi
  fi

  if [ -z "$url" ] || [[ "$url" == *'${{'* ]]; then
    echo "DATABASE_URL is not available as a resolved value from Railway or Doppler stg." >&2
    return 1
  fi
  printf '%s' "$url"
}
