# GKT-749 — Harbor PR #4449 merge-gate (read-only)

**Idempotency:** `GKT-355:auto:4449-merge-gate-6093fca7`  
**Linear:** [GKT-749](https://linear.app/gkt/issue/GKT-749)  
**Subject PR:** [EBWiki/EBWiki#4449](https://github.com/EBWiki/EBWiki/pull/4449) — *Harbor 0: in-tree Harbor tasks and layout-only CI (no search stack)*  
**Prior audit:** [GKT-736](https://linear.app/gkt/issue/GKT-736) — CI green on tip `6093fca7`  
**Audit mode:** read-only (no undraft, no Approve, no merge on #4449)  
**Parent [GKT-355](https://linear.app/gkt/issue/GKT-355):** remains open (runway / merge GO tracking)  
**Captured (UTC):** 2026-10-05T19:46:38Z  

---

## Section A — Merge-gate bar

| Gate | Pass | Fail |
| --- | --- | --- |
| **Tip SHA** | Live head matches expected prefix `6093fca7` | Drift or unverifiable head |
| **CI** | All required checks on head are `success` (skipped optional jobs OK) | Any required check failed, cancelled, or pending |
| **Mergeable** | GitHub `mergeable: true`, no conflict vs `main` | Conflicts or not mergeable |
| **Draft / review** | Record state; draft + `REVIEW_REQUIRED` are expected pre-merge gates, not audit failures | N/A unless paired with CI/conflict failures |

**Merge-gate pass:** tip match, CI green, conflict-free mergeable. Draft and missing Approve are workflow steps after this gate.

---

## Section B — Evidence and RESULT

### Evidence snapshot

| Field | Value |
| --- | --- |
| **Tip SHA (live)** | `6093fca7d405f13719f6628abf88a364a05619a8` |
| **Expected tip** | `6093fca7…` — **match (no drift)** |
| **Draft?** | **Yes** (`isDraft: true`) |
| **PR state** | `OPEN` |
| **Head branch** | `cursor/harbor-only-draft-pr-9193` |
| **Base** | `main` @ `302c9a1db219f30c7b498e14323f112ac03b314e` |
| **Compare to `main`** | `ahead_by: 1`, `behind_by: 0`, `status: ahead` |
| **Mergeable (GitHub)** | `mergeable: true` (`MERGEABLE`) |
| **Merge state** | `mergeStateStatus: BLOCKED` (draft + review required; not conflicts) |
| **Review decision** | `REVIEW_REQUIRED` (no submitted reviews on tip) |
| **Review requests** | None assigned (`users: []`, `teams: []`) |

#### CI on head `6093fca7…`

| Check | Conclusion |
| --- | --- |
| CI — rspec | success |
| CI — rubocop | success |
| CI — brakeman | success |
| CI — markdown-link-checker | success |
| Harbor tasks — Check Harbor task layout (oracle-only, no paid models) | success |
| CodeQL — Analyze (ruby, python, javascript-typescript, actions) | success |
| CodeQL — CodeQL | success |
| Dependabot auto-merge — dependabot | skipped |
| CodeRabbit | success (auto review skipped — repo policy) |

### RESULT

```
MERGE-GATE: PASS
TIP:        6093fca7d405f13719f6628abf88a364a05619a8 (matches 6093fca7; no drift)
DRAFT:      YES (expected pre-review)
CI:         PASS (required checks success on head)
MERGEABLE:  YES (conflict-free); BLOCKED only by draft + REVIEW_REQUIRED

Recommendations (prefer GO, not LOCKED):
  1. Undraft #4449:              GO — CI green on tip; safe to mark ready for review when author chooses
  2. @gktreviewer Approve:       GO — CODEOWNERS Approve still required (none on tip); use GitHub Request review
  3. Mark merge GO (GKT-355):    GO — Harbor landing ready after undraft + human Approve; do not merge in this audit

Hard blockers for merge today: draft PR, missing CODEOWNERS Approve — not CI or merge conflicts.
Overall merge-gate: GO (not LOCKED).
```

---

## Ticket disposition

- **GKT-749:** Done (audit-only merge-gate; this artifact).  
- **GKT-355:** Stays open (parent runway).  
- **Out of scope:** undraft #4449, request/self-Approve, merge, edits to #4449.
