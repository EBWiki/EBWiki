#!/usr/bin/env bash
# Helpers for OpenTofu `state show -json` output (version line + values document).
set -euo pipefail

# Read multi-line `tofu state show -json` from stdin; print the resource id from the values document.
infra_tofu_state_show_json_resource_id() {
  jq -r 'select(.values.root_module?) | .values.root_module.resources[0].values.id // empty'
}
