#!/usr/bin/env bash
# EXIT traps for temp dirs that keep a sourcing caller's own EXIT trap.
# A subshell shows its parent's EXIT trap without running it, so inside a
# subshell the caller trap is neither chained nor restored.
set -euo pipefail

infra_exit_trap_set_status() {
  return "$1"
}

# Runs CLEANUP on exit, then the caller's EXIT trap with the original exit status.
infra_exit_trap_push() {
  local cleanup="$1" prev=""
  INFRA_PREV_EXIT_TRAP=""
  if ((BASH_SUBSHELL == 0)); then
    INFRA_PREV_EXIT_TRAP="$(trap -p EXIT)"
  fi
  if [[ -z "$INFRA_PREV_EXIT_TRAP" ]]; then
    # shellcheck disable=SC2064 # the cleanup command is fixed when the trap is set
    trap "$cleanup" EXIT
    return 0
  fi
  eval "set -- $INFRA_PREV_EXIT_TRAP"
  prev="$3"
  # shellcheck disable=SC2064,SC2154 # both commands are fixed now; the exit status is read when the trap runs
  trap "infra_exit_rc=\$?; $cleanup; set +e; infra_exit_trap_set_status \"\$infra_exit_rc\"; $prev" EXIT
}

# Puts back the caller's EXIT trap saved by infra_exit_trap_push.
infra_exit_trap_pop() {
  if [[ -n "${INFRA_PREV_EXIT_TRAP:-}" ]]; then
    eval "$INFRA_PREV_EXIT_TRAP"
  else
    trap - EXIT
  fi
  INFRA_PREV_EXIT_TRAP=""
}
