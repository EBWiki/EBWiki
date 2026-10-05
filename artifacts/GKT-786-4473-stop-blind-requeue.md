# GKT-786 — STOP blind CI re-queue escalation for PR #4473

Read-only escalation for draft landing PR [#4473](https://github.com/EBWiki/EBWiki/pull/4473) at tip **`79940ee`**. Parent **[GKT-355](https://linear.app/gkt/issue/GKT-355)** stays open. Standing rule from **prompts #22** / **[GKT-779](https://linear.app/gkt/issue/GKT-779)**: **do not blind re-queue GitHub Actions** when failures are hosted-runner acquisition / queue cancels. This spike is **audit-only** — no product writes, no Actions re-run, no ping to Mark.

| Field | Value |
| --- | --- |
| Landing PR | [#4473](https://github.com/EBWiki/EBWiki/pull/4473) — *Restore Compose-based Docker local stack and ebwiki:dev tag (GKT-721)* |
| Branch | `cursor/compose-docker-dev-residual-6df7` |
| Tip (short) | `79940ee` |
| Tip (full) | `79940ee374caa3155347396c01334d31c236b33e` |
| Snapshot captured (UTC) | 2026-10-05T20:27:43Z |
| Idempotency | `GKT-355:auto:4473-stop-blind-requeue-escalate-79940ee-20261005` |
| Linear | [GKT-786](https://linear.app/gkt/issue/GKT-786) (escalation) |
| Related pattern | [GKT-769](https://linear.app/gkt/issue/GKT-769), [GKT-775](https://linear.app/gkt/issue/GKT-775) |
| Policy | [GKT-779](https://linear.app/gkt/issue/GKT-779) / prompts #22 — STOP blind re-queue |

---

## Assumption

1. **Tip SHA `79940ee` is authoritative** for merge and CI interpretation on #4473 (GitHub `headRefOid` matches at snapshot).
2. **CI job conclusions of `cancelled` with zero steps and annotation *“The job was not acquired by Runner of type hosted even after multiple attempts”* are infrastructure queue failures**, not application lint/test/security regressions.
3. **A manual re-trigger (re-queue) without queue relief reproduces the same pattern**: fast jobs that acquire runners (e.g. **rspec**) pass; sibling jobs sit ~15 minutes then cancel — matching GKT-769 / GKT-775 evidence.
4. **First push CI run `37363437104` on the same SHA is the best available substantive signal** for rubocop / markdown-link-checker / rspec on this tip; brakeman on that run also hit runner acquisition cancel (not a Brakeman finding).

---

## Pass / fail bar

Encoding follows GKT-784: prefer **GO** / **WAIT**; never **“locked”**.

| Decision | PASS (GO) | FAIL (WAIT) |
| --- | --- | --- |
| **Merge #4473** | All required CI checks on tip **`79940ee`** report **success** (including **brakeman**, **rubocop**, **markdown-link-checker**, **rspec**); plus draft undraft, review, and any GKT-355 epic gates Mark owns separately. | Any required check **failed** or **cancelled** on tip; and/or **REVIEW_REQUIRED** / draft still blocking. |
| **Blind re-queue Actions on this tip** | **Never GO** under GKT-779 when cancels match runner-acquisition pattern and a prior run already showed pass on overlapping jobs. | **STOP** — record **WAIT** on infra; do not stack re-triggers (~15m queued cancels). |
| **This escalation ticket (GKT-786)** | Artifact filed with evidence + recommendation; parent GKT-355 remains open. | — |

---

## Evidence

### Tip verification

| Check | Result |
| --- | --- |
| GitHub PR `head.sha` | `79940ee374caa3155347396c01334d31c236b33e` |
| PR state | **Open**, **draft** |
| Mergeable (GitHub) | MERGEABLE |
| Mergeable state | **blocked** (checks / branch protection) |
| Review decision | **REVIEW_REQUIRED** |

### CI run A — first push (substantive signal)

Workflow **CI** run [**37363437104**](https://github.com/EBWiki/EBWiki/actions/runs/37363437104) on `79940ee` (2026-10-05T19:26:49Z → 19:41:52Z, conclusion **failure** due to cancelled jobs):

| Job | Conclusion | Duration / notes |
| --- | --- | --- |
| **rspec** | **success** | Ran full steps (~3m) |
| **rubocop** | **success** | Ran full steps |
| **markdown-link-checker** | **success** | Ran full steps |
| **brakeman** | **cancelled** | ~15m1s; **0 steps**; annotation: runner not acquired |

### CI run B — re-trigger (GKT-769 pattern; do not repeat)

Workflow **CI** run [**37367922066**](https://github.com/EBWiki/EBWiki/actions/runs/37367922066) on same `79940ee` (2026-10-05T20:08:52Z → 20:23:55Z, conclusion **failure**):

| Job | Conclusion | Duration / notes |
| --- | --- | --- |
| **rspec** | **success** | Acquired runner; ~3m18s |
| **rubocop** | **cancelled** | ~15m2s; **0 steps**; runner not acquired |
| **markdown-link-checker** | **cancelled** | ~15m1s; **0 steps** |
| **brakeman** | **cancelled** | ~15m2s; **0 steps** |

Example annotation (rubocop job `111957508906`, re-trigger run):

> The job was not acquired by Runner of type hosted even after multiple attempts

### Rollup at snapshot (`gh pr checks 4473`)

Latest visible conclusions favor run B for rubocop / markdown / brakeman (**fail** / cancelled), while **rspec** **pass** — misleading “red” PR checks despite run A greens on three jobs.

### CodeQL (same tip, separate workflow)

CodeQL jobs on run [37363433249](https://github.com/EBWiki/EBWiki/actions/runs/37363433249): **Analyze (ruby|python|javascript-typescript)** **success**; **Analyze (actions)** **cancelled** (~15m, same runner-acquisition class).

---

## Recommendation

| Field | Value |
| --- | --- |
| **Blind re-queue** | **STOP** — do not re-run / re-queue CI on `79940ee` in hope of clearing cancelled jobs (GKT-779 / prompts #22). |
| **Merge #4473** | **WAIT** — branch protection rollup is **blocked**; tip lacks green **brakeman** and post-retrigger greens on rubocop / markdown-link-checker. |
| **Substantive code signal** | **Partial GO signal** from run A (rspec + rubocop + markdown-link-checker success on tip); **not** sufficient for merge GO. |
| **Infra** | Treat as **hosted runner queue / acquisition** under parent **[GKT-355](https://linear.app/gkt/issue/GKT-355)**; prefer organic queue recovery or a **single deliberate** re-run only after queue relief — not stacked blind re-queues. |
| **Human ping** | **No** Mark ping from this escalation. |
| **Parent GKT-355** | **Open** — this file does not close the epic. |

**Overall:** **WAIT** on merge; **STOP** on blind CI re-queue. Not **locked** — record blockers and wait for infra / human merge policy rather than forcing another Actions retry on the same tip.

---

## Section B — RESULT

| Field | Value |
| --- | --- |
| GKT-786 deliverable | This file (`artifacts/GKT-786-4473-stop-blind-requeue.md`) |
| Tip matches `79940ee`? | **Yes** |
| Re-trigger run 37367922066 | **rspec pass**; **rubocop / markdown / brakeman cancelled** ~15m (runner acquisition) |
| Same pattern as GKT-775? | **Yes** (queue cancel, not test output) |
| Blind re-queue? | **STOP** |
| Merge-ready? | **No** — **WAIT** |
| Parent GKT-355 | **Open** |
| Agent actions taken | Read-only GitHub audit; **no** Actions re-queue; **no** product diff on #4473 branch |
| Reviewer / agent | Cursor Agent (escalation artifact) |
| Date (UTC) | 2026-10-05 |

---

## References

- Landing PR: [#4473](https://github.com/EBWiki/EBWiki/pull/4473)
- First CI run: [37363437104](https://github.com/EBWiki/EBWiki/actions/runs/37363437104)
- Re-trigger CI run (GKT-769 evidence): [37367922066](https://github.com/EBWiki/EBWiki/actions/runs/37367922066)
- Parent epic: [GKT-355](https://linear.app/gkt/issue/GKT-355)
- Policy: [GKT-779](https://linear.app/gkt/issue/GKT-779)
