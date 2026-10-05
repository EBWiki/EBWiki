# GKT-736 — Harbor PR #4449 readiness spike (read-only)

**Idempotency:** `GKT-355:auto:4449-readiness-report`  
**Linear:** [GKT-736](https://linear.app/gkt/issue/GKT-736)  
**Subject PR:** [EBWiki/EBWiki#4449](https://github.com/EBWiki/EBWiki/pull/4449) — *Harbor 0: in-tree Harbor tasks and layout-only CI (no search stack)*  
**Audit mode:** read-only (no undraft, no merge, no edits to #4449)  
**Parent [GKT-355](https://linear.app/gkt/issue/GKT-355):** remains open (runway / merge GO tracking)  
**Captured (UTC):** 2026-10-05T19:38:35Z  

---

## Section A — Assumption and pass/fail bar

### Assumption

This spike treats **Harbor 0** as defined on #4449: land in-tree `harbor/` (smoke, boot, spec-fix tasks, `ebwiki-dev` sidecars, `registry.json`), `docs/SPIKE_HARBOR.md`, root `/jobs` gitignore, and **layout-only** CI (`python3 harbor/bin/check-tasks`) with **no** `pg_search` / CaseSearch / Elasticsearch application changes and **no** repo-root Compose/Dockerfile refresh. Merge readiness is judged against **current `main`** with CODEOWNERS human **Approve** from `@gktreviewer` (see `.github/CODEOWNERS`). CI green on the PR head commit is necessary but not sufficient for merge.

### Pass/fail bar

| Criterion | Pass | Fail |
| --- | --- | --- |
| **Tip SHA** | Live PR head matches expected tip prefix `6093fca7` (full SHA recorded below) | Head SHA differs or cannot be verified |
| **Scope (landing PR)** | Diff limited to Harbor 0 harness + smallest unlock (workflow, docs, gitignore); no search-stack or unrelated areas | Mixed concerns, search/ES/pg_search app changes, or unrelated drive-by edits |
| **CI matrix** | All **required** check runs on head are `success` (skipped optional jobs OK) | Any required check `failure`, `cancelled`, or missing on head |
| **Mergeability** | GitHub reports mergeable with **no** merge conflicts vs `main` (`compare` status `ahead`, `behind_by` 0) | `CONFLICTING` or behind `main` with unresolved drift |
| **Review gate** | `REVIEW_REQUIRED` with no Approve yet is **expected**; does not alone fail the spike | N/A as hard fail unless paired with CI/scope failures |
| **Draft** | Draft is **expected** for Harbor 0; recorded as a pre-merge gate, not a spike fail | N/A as hard fail unless policy requires ready-for-review for this audit |

**Overall spike pass:** all hard rows pass (tip, scope, CI, mergeability). Draft and missing Approve are **workflow gates**, not audit failures, when CI and scope pass.

---

## Section B — Evidence and RESULT

### Evidence snapshot

| Field | Value |
| --- | --- |
| **Tip SHA (live)** | `6093fca7d405f13719f6628abf88a364a05619a8` |
| **Expected tip** | `6093fca7…` — **match** |
| **Draft?** | **Yes** (`isDraft: true`) |
| **Head branch** | `cursor/harbor-only-draft-pr-9193` |
| **Base** | `main` @ `302c9a1db219f30c7b498e14323f112ac03b314e` |
| **Compare to `main`** | `status: ahead`, `ahead_by: 1`, `behind_by: 0` |
| **Mergeable (GitHub)** | `mergeable: true` (`MERGEABLE`) |
| **Merge state** | `mergeStateStatus: BLOCKED` (draft + review required; not conflict) |
| **Review decision** | `REVIEW_REQUIRED` (no submitted reviews on tip) |
| **Diff size** | 31 files, +866 / −0, 1 commit |
| **Linear (PR body)** | Harbor 0 **GKT-631**; parent runway **GKT-356** (not closed here) |

#### CI matrix (head `6093fca7…`)

| Workflow | Job / check | Conclusion |
| --- | --- | --- |
| **CI** | rspec | success |
| **CI** | rubocop | success |
| **CI** | brakeman | success |
| **CI** | markdown-link-checker | success |
| **Harbor tasks** | Check Harbor task layout (oracle-only, no paid models) | success |
| **CodeQL** | Analyze (ruby) | success |
| **CodeQL** | Analyze (python) | success |
| **CodeQL** | Analyze (javascript-typescript) | success |
| **CodeQL** | Analyze (actions) | success |
| **CodeQL** | CodeQL | success |
| **Dependabot auto-merge** | dependabot | skipped |
| **Status** | CodeRabbit | success (review skipped — auto reviews disabled) |

**Scope spot-check (changed paths):** `.github/workflows/harbor.yml`, `.gitignore`, `docs/SPIKE_HARBOR.md`, `harbor/**` only — **no** application Ruby changes for search stack; aligns with PR out-of-scope statement.

**Advisory (reviewability):** 31 files exceeds the ~25-file landing-PR smell in `.cursor/rules/landing-pr.mdc`, but paths cluster under `harbor/` and are one named concern; not treated as a hard fail for this Harbor 0 audit.

**Not verified in this audit (explicit non-goals):** local `harbor run` oracle trials, Docker image `:dev` build, paid-agent runs (documented as follow-on / out of CI scope).

### RESULT

```
SPIKE: PASS
TIP:   6093fca7d405f13719f6628abf88a364a05619a8 (matches 6093fca7)
CI:    PASS (all required checks success on head)
MERGE: CONFLICT-FREE (mergeable); BLOCKED only by draft + REVIEW_REQUIRED

Recommendations (prefer GO, not LOCKED):
  Undraft #4449:              GO — CI green on tip; suitable to mark ready for review when author chooses
  @gktreviewer Approve:       GO — request CODEOWNERS review/Approve (no Approve on tip yet; expected)
  Mark merge GO (GKT-355/356): GO — Harbor 0 landing-ready pending undraft + human Approve; do not merge in this audit

Hard blockers for merge today: draft PR, missing CODEOWNERS Approve (policy), not CI or conflicts.
Overall readiness: GO (not LOCKED) for Harbor 0 review runway.
```

---

## Ticket disposition

- **GKT-736:** Done (audit-only spike; this artifact).  
- **GKT-355:** Stays open (parent runway / merge GO).  
- **Actions explicitly out of scope for this run:** undraft #4449, request/self-Approve, merge, code changes on #4449.
