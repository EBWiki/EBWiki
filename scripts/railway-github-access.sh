#!/usr/bin/env bash
# Verifies the Railway GitHub App on the EBWiki org can access EBWiki/EBWiki, then grants repo access if needed.
set -euo pipefail

ORG="EBWiki"
REPO="${ORG}/EBWiki"

command -v gh >/dev/null 2>&1 || { echo "Install GitHub CLI (gh) and authenticate."; exit 1; }

org_installation_id() {
  gh api "/orgs/${ORG}/installations" --jq '.installations[] | select(.app_slug=="railway-app") | .id' | head -1
}

user_installation_id() {
  gh api /user/installations --jq '.installations[] | select(.app_slug=="railway-app") | .id' | head -1
}

INSTALLATION_ID="$(org_installation_id)"
if [ -z "${INSTALLATION_ID}" ]; then
  if [ -n "$(user_installation_id)" ]; then
    echo "Railway GitHub App is installed for your user account but not on org ${ORG}." >&2
    echo "Install it on https://github.com/organizations/${ORG}/settings/installations with access to ${REPO}." >&2
    exit 1
  fi
  echo "No Railway GitHub app installation found for org ${ORG}." >&2
  echo "Install the Railway GitHub App on https://github.com/organizations/${ORG}/settings/installations first." >&2
  exit 1
fi

installation_repos() { # jq field
  gh api "/user/installations/${INSTALLATION_ID}/repositories" --paginate --jq ".repositories[]?.$1"
}

REPO_ID="$(gh api "/repos/${REPO}" --jq .id)"
[ -n "$REPO_ID" ] || { echo "Could not read the id of ${REPO}." >&2; exit 1; }
visible_ids="$(installation_repos id)"
if ! grep -qxF "${REPO_ID}" <<<"$visible_ids"; then
  echo "Railway GitHub App installation ${INSTALLATION_ID} cannot see ${REPO} yet; granting access..." >&2
  gh api -X PUT "/user/installations/${INSTALLATION_ID}/repositories/${REPO_ID}"
fi

visible_names="$(installation_repos full_name)"
if ! grep -Fxq "${REPO}" <<<"$visible_names"; then
  echo "Railway GitHub App still cannot read ${REPO} after grant." >&2
  exit 1
fi

echo "Railway GitHub App (org ${ORG}, installation ${INSTALLATION_ID}) can read ${REPO}."
