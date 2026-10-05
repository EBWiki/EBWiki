# GKT-738 — PR #4474 readiness after restack onto #4472 tip

| Field | Value |
| --- | --- |
| Linear | [GKT-738](https://linear.app/gkt/issue/GKT-738) |
| PR | [#4474](https://github.com/EBWiki/EBWiki/pull/4474) — *Restore homonym request-spec assertion on #4472 stack (GKT-720)* |
| Parent stack | [#4472](https://github.com/EBWiki/EBWiki/pull/4472) — *Integrate Hanami friendly-photos search stack on SourcePolicy gate (GKT-707)* |
| Parent epic | GKT-176 (remains open) |
| Prior audit | GKT-727 — SCOPE OK on stale base `ebd204b9` (pre-restack) |
| Idempotency | `GKT-176:auto:4474-readiness-after-restack-4c371f80` |
| Audit mode | Read-only (no undraft, merge, or force-push) |
| Audited at (UTC) | 2026-10-05T19:42:00Z |

---

## Section A — Assumptions and pass/fail bar

### Assumptions

1. **Tip/base SHAs** were verified by parent GKT-733 and re-checked here via `gh pr view 4474` and local `git rev-parse` on branch `cursor/4472-homonym-request-spec-c59a`.
2. **Restack intent:** PR #4474’s merge base is the current tip of the #4472 integration branch (`130ac1e7…`), not the pre-restack base (`ebd204b9…` from GKT-727).
3. **Scope unchanged:** The landing diff is still the single #4468 hunk — one `include` expectation in `apps/hanami/spec/requests/friendly_photos_spec.rb` — atop the integrated search stack.
4. **Ship lock:** #4474 stays **draft** until #4472 (and upstream stack) is approved; GKT-176 stays open; child GKT-720 closes via #4474 only after stack policy allows merge.
5. **CI:** GitHub reported `mergeStateStatus: UNSTABLE` with required checks still **QUEUED** shortly after the restack merge commit; treating pending CI as a **caveat**, not an automatic scope fail (per ticket).

### Pass/fail bar

| Outcome | Criteria |
| --- | --- |
| **PASS (GO, draft-locked)** | Head `4c371f80…`, base `130ac1e7…`; `mergeable: MERGEABLE`; `isDraft: true`; diff scope = 1 file / +1 line spec only; homonym assertion matches template substring `Possible historical homonym`; stack base branch = #4472 head branch; no undraft/merge performed in this audit. |
| **PASS WITH CAVEAT** | All PASS criteria above, but required CI not yet green (QUEUED/IN_PROGRESS) or `mergeStateStatus: UNSTABLE`. |
| **FAIL** | Wrong head/base SHA; conflicting merge; scope beyond the homonym spec line; draft cleared without approval; homonym string mismatch; base not on #4472 tip. |

### Evidence

#### Commit identity

| Role | SHA | Notes |
| --- | --- | --- |
| **Tip (head)** | `4c371f80e79e08f5dd41079607abf40f4b1d07ae` | Merge restack (`GKT-176:auto:4474-restack-on-4472-130ac1e7`) + GKT-720 commit `a405e5fd…` |
| **Base** | `130ac1e73e34235da50617d91080cad0501977e4` | Matches #4472 `headRefOid` at audit time |
| **Functional delta** | `130ac1e7..4c371f80` | `apps/hanami/spec/requests/friendly_photos_spec.rb` **+1** line only |

#### GitHub PR state (2026-10-05T19:42Z)

| Check | Value |
| --- | --- |
| `state` | OPEN |
| `isDraft` | **true** |
| `mergeable` | **MERGEABLE** |
| `mergeStateStatus` | **UNSTABLE** (checks incomplete) |
| `headRefName` | `cursor/4472-homonym-request-spec-c59a` |
| `baseRefName` | `cursor/hanami-friendly-photos-integrated-search-stack-c34d` (#4472 branch) |

#### CI matrix (status at audit time)

| Workflow | Job | Status | Conclusion |
| --- | --- | --- | --- |
| CI | rspec | QUEUED | — |
| CI | brakeman | QUEUED | — |
| CI | rubocop | QUEUED | — |
| CI | markdown-link-checker | QUEUED | — |
| Hanami | rspec | QUEUED | — |
| Hanami | rubocop | QUEUED | — |
| Hanami | dawnscanner | QUEUED | — |
| Dependabot auto-merge | dependabot | COMPLETED | SKIPPED |
| (status) | CodeRabbit | — | SUCCESS |

Recent Actions runs on `cursor/4472-homonym-request-spec-c59a`: Hanami `37364518919`, CI `37364519053` (both **queued** at audit).

#### Scope diff (product vs spec)

Restacked diff adds exactly:

```ruby
expect(last_response.body).to include("Possible historical homonym")
```

in the existing `"searches locked sources and flags likely mugshots"` example.

### Homonym expectation (single-line substring)

| Layer | Text |
| --- | --- |
| **Request spec (added line)** | `expect(last_response.body).to include("Possible historical homonym")` |
| **Show template** | `<p class="flash-error">Possible historical homonym — do not use.</p>` when `hit.likely_homonym` |

**Confirmation:** The spec uses a **single-line substring** match on `Possible historical homonym`, which is present in the rendered warning copy (prefix before the em dash). This aligns with the #4468 / GKT-720 intent and does not require matching the full `" — do not use."` suffix.

### Comparison to GKT-727 (stale base)

| Dimension | GKT-727 (`ebd204b9…` base) | GKT-738 (post-restack) |
| --- | --- | --- |
| Scope | SCOPE OK (1 spec line) | **Unchanged** — still 1 file, +1 line |
| Stack anchor | Stale vs current #4472 tip | **Correct** — base = #4472 tip `130ac1e7…` |
| CI | (prior run) | **Re-run pending** — queued after restack |

---

## Section B — RESULT

**Verdict:** **PASS WITH CAVEAT — GO (draft-locked)**

**Summary:** Post-restack #4474 at tip `4c371f80e79e08f5dd41079607abf40f4b1d07ae` on base `130ac1e73e34235da50617d91080cad0501977e4` remains **in scope** (same single homonym request-spec line as GKT-727), is **mergeable**, stays **draft**, and is correctly stacked on #4472. Required CI was still **QUEUED** / `UNSTABLE` at audit time — re-check Actions before undraft or merge.

**Recommendation:**

1. **Do not undraft or merge #4474** until #4472 stack approval and green required checks (Hanami + CI rspec/rubocop/brakeman/dawnscanner/markdown-link-checker).
2. **Keep #4474 draft** — satisfies “GO not locked” while GKT-176 remains open.
3. **No further code changes required** for GKT-738; when CI completes, a quick CI-only follow-up audit is optional if any job fails.
4. **Merge order (when unlocked):** land #4472 stack first, then #4474 as the GKT-720 spec unlock on that tip.

**Idempotency marker:** `GKT-176:auto:4474-readiness-after-restack-4c371f80` — audit complete; no repository write actions on #4474 beyond this artifact file.
