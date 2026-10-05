# GKT-790 — EBWiki #4474 stack / merge-path packet (after #4472)

**Idempotency:** `GKT-176:auto:4474-stack-after-4472-packet-20261005`  
**Linear:** GKT-790 (read-only pass; parent **GKT-176** remains open)  
**Observed (UTC):** 2026-10-05T20:29:13Z  
**Scope:** Read-only GitHub verification. No CI re-queue. No product writes. No Mark ping.

---

## Assumption

- Stack intent is unchanged: **#4474** (`cursor/4472-homonym-request-spec-c59a`, GKT-720) stays stacked on **#4472** (`cursor/hanami-friendly-photos-integrated-search-stack-c34d`, GKT-707).
- Expected live tips match automation inputs: **#4472 → `130ac1e7`**, **#4474 → `4c371f80`** (restack merge commit `GKT-176:auto:4474-restack-on-4472-130ac1e7`).
- Merge order is **#4472 before #4474**; #4474’s base branch is #4472’s head, not `main`.
- **#4472 CI WAIT** follows the GKT-775 / GKT-779 pattern: required checks ended **cancelled** on long-running jobs (~15m), `run_attempt: 3` — do **not** blind re-queue.

---

## Pass / fail bar

| Outcome | Bar |
|--------|-----|
| **PASS** | Remote tips match `130ac1e7` / `4c371f80`; #4474 base OID equals #4472 head OID; both PRs draft as expected; #4472 CI classified **WAIT** (cancelled CI `rspec` + Hanami `dawnscanner`); #4474 required CI **GO** on its head; merge-path recommendation is **#4472 before #4474** with no re-queue. |
| **FAIL** | Tip drift, broken stack base/head linkage, mistaken **GO** on #4472 merge, or any instruction to re-queue / ping Mark / close GKT-176. |

**This run:** **PASS** (evidence below).

---

## Live tips (confirmed)

| PR | Branch | Tip (full) | Tip (short) | Draft | GitHub |
|----|--------|------------|-------------|-------|--------|
| [#4472](https://github.com/EBWiki/EBWiki/pull/4472) | `cursor/hanami-friendly-photos-integrated-search-stack-c34d` | `130ac1e73e34235da50617d91080cad0501977e4` | `130ac1e7` | **yes** | [PR #4472](https://github.com/EBWiki/EBWiki/pull/4472) |
| [#4474](https://github.com/EBWiki/EBWiki/pull/4474) | `cursor/4472-homonym-request-spec-c59a` | `4c371f80e79e08f5dd41079607abf40f4b1d07ae` | `4c371f80` | **yes** | [PR #4474](https://github.com/EBWiki/EBWiki/pull/4474) |

Fetched `origin` refs after `git fetch`; `git rev-parse` matches GitHub PR `headRefOid` / `baseRefOid`.

**Stack linkage:** #4474 `baseRefOid` = `130ac1e7…` = #4472 `headRefOid`. #4472 base = `cursor/hanami-candidate-search-source-policy-gate-c0e4` ([#4466](https://github.com/EBWiki/EBWiki/pull/4466) line).

---

## CI: GO / WAIT

### #4472 — **WAIT** (do not re-queue)

- **mergeStateStatus:** `UNSTABLE` (GitHub).
- **Blocking / indeterminate required checks on tip `130ac1e7`:**
  - **CI → `rspec`:** `CANCELLED` (started `2026-10-05T20:12:00Z`, completed `2026-10-05T20:27:01Z`, ~15m) — [run 37364301945](https://github.com/EBWiki/EBWiki/actions/runs/37364301945/job/111958584690).
  - **Hanami → `dawnscanner`:** `CANCELLED` (started `2026-10-05T20:11:58Z`, completed `2026-10-05T20:26:59Z`, ~15m) — [run 37364302319](https://github.com/EBWiki/EBWiki/actions/runs/37364302319/job/111958570525).
- Both workflows on this SHA: **`run_attempt: 3`**, overall workflow **conclusion: failure** (cancelled jobs).
- **Green on same SHA (does not clear WAIT):** CI `brakeman`, `rubocop`, `markdown-link-checker`; Hanami `rubocop`; Hanami `rspec` success on a later job in the same Hanami run (`2026-10-05T20:22:43Z`–`20:23:25Z`).
- **CodeRabbit:** success (non-merge gate).

**Operator note:** Treat as **WAIT**, not “locked.” Per GKT-775 / GKT-779, **stop blind re-queue** on this ~15m cancelled-runner pattern until a deliberate remediation path is chosen.

### #4474 — **GO** (checks on head); merge-path **WAIT**

- **mergeStateStatus:** `CLEAN`; **mergeable:** `MERGEABLE`.
- **Required checks on tip `4c371f80`:** all **SUCCESS** — CI `rspec`, `brakeman`, `rubocop`, `markdown-link-checker`; Hanami `rspec`, `rubocop`, `dawnscanner` ([CI run 37364519053](https://github.com/EBWiki/EBWiki/actions/runs/37364519053), [Hanami run 37364518919](https://github.com/EBWiki/EBWiki/actions/runs/37364518919)).
- **Merge-path:** **WAIT** — base is #4472’s branch; landing #4474 before #4472 would bypass stack order even though head CI is green.

---

## Recommendation

1. **Merge order:** Land **[#4472](https://github.com/EBWiki/EBWiki/pull/4472) before [#4474](https://github.com/EBWiki/EBWiki/pull/4474)** onto the #4466 line (then continue stack policy upstream as already tracked under GKT-176).
2. **#4472:** **WAIT** — do **not** re-queue CI from this packet; resolve cancelled `rspec` / `dawnscanner` only via an explicit, non-blind follow-up (outside this read-only pass).
3. **#4474:** Hold as draft stacked on #4472; after #4472 is green and merged, restack/rebase if #4472 tip moves, then re-verify CI on the new head before merge.
4. **GKT-176:** Keep **open** (parent orchestration unchanged).
5. **GKT-790:** Packet complete for idempotency key above; no Linear write in this pass (MCP auth unavailable).

---

## Evidence commands (2026-10-05)

```text
gh pr view 4472 --json number,isDraft,headRefName,baseRefName,mergeStateStatus,statusCheckRollup
gh pr view 4474 --json number,isDraft,headRefName,baseRefName,baseRefOid,headRefOid,mergeStateStatus,statusCheckRollup
git fetch origin cursor/hanami-friendly-photos-integrated-search-stack-c34d cursor/4472-homonym-request-spec-c59a
git rev-parse origin/cursor/hanami-friendly-photos-integrated-search-stack-c34d  # 130ac1e7...
git rev-parse origin/cursor/4472-homonym-request-spec-c59a                      # 4c371f80...
gh api repos/EBWiki/EBWiki/actions/runs/37364301945 --jq '.head_sha,.run_attempt,.conclusion'
gh api repos/EBWiki/EBWiki/actions/runs/37364302319 --jq '.head_sha,.run_attempt,.conclusion'
```
