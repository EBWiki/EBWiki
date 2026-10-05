# GKT-759 — PR #4450 tip CI snapshot (audit-only)

Point-in-time CI, draft, and review snapshot for draft landing PR [#4450](https://github.com/EBWiki/EBWiki/pull/4450) at expected tip **`413463c7`**. Parent **[GKT-175](https://linear.app/gkt/issue/GKT-175)** stays open. This spike is **audit-only**; it does **not** merge, undraft, or mark merge GO.

| Field | Value |
| --- | --- |
| Landing PR | [#4450](https://github.com/EBWiki/EBWiki/pull/4450) — *Add friendly photo finder with mugshot workflow (clean recreate)* |
| Branch | `cursor/friendly-photos-clean-9ad4` |
| Expected tip (short) | `413463c7` |
| Expected tip (full) | `413463c78b0dfef8e77df0b4575a689d5a70cfa4` |
| Tip commit subject | `docs(GKT-739): add Railway staging walkthrough checklist for #4450` |
| Base (`main`) | `302c9a1db219f30c7b498e14323f112ac03b314e` |
| Snapshot captured (UTC) | 2026-10-05T19:56:54Z |
| Idempotency | `GKT-175:auto:4450-tip-ci-snapshot-413463c7` |
| Linear | [GKT-759](https://linear.app/gkt/issue/GKT-759) |

---

## Section A — Tip verification

| Check | Result |
| --- | --- |
| GitHub PR `head.sha` | `413463c78b0dfef8e77df0b4575a689d5a70cfa4` |
| Matches expected `413463c7`? | **Yes** (prefix match; full SHA above) |
| Commits on PR (count) | 7 |
| Changed files (GitHub) | 108 (+5699 / −34) |

---

## Section A — CI matrix (head SHA `413463c7`)

GitHub **combined status** context: **CodeRabbit** → success (*Review skipped: automatic reviews are disabled*).

| Job / check | Workflow | Status | Conclusion | Notes |
| --- | --- | --- | --- | --- |
| **rspec** | CI | completed | **cancelled** | Run [37365045554](https://github.com/EBWiki/EBWiki/actions/runs/37365045554) — runner not acquired |
| **rubocop** | CI | completed | **cancelled** | Same run; infra cancel, not lint failure |
| **brakeman** | CI | completed | **cancelled** | Same run |
| **markdown-link-checker** | CI | completed | **cancelled** | Same run |
| **playwright** | E2E | completed | **success** | Run [37364941173](https://github.com/EBWiki/EBWiki/actions/runs/37364941173) |
| **Analyze (ruby)** | CodeQL | completed | **success** | Run [37364934587](https://github.com/EBWiki/EBWiki/actions/runs/37364934587) |
| **Analyze (python)** | CodeQL | completed | **success** | Same suite |
| **Analyze (actions)** | CodeQL | completed | **success** | Same suite |
| **Analyze (javascript-typescript)** | CodeQL | completed | **success** | Same suite |
| **CodeQL** (aggregate) | — | completed | **success** | |
| **dependabot** | Dependabot auto-merge | completed | **skipped** | Expected for feature PR |

**CI workflow summary for tip push:** GitHub Actions CI run **37365045554** ended **failure** after ~15m: all four CI jobs failed with annotation *The job was not acquired by Runner of type hosted even after multiple attempts* (queue/infra, not application test output).

**Prior green CI on branch (pre–tip docs commit):** Run [37314213973](https://github.com/EBWiki/EBWiki/actions/runs/37314213973) at tip `9f148f48` (2026-10-05T13:06Z) — **rspec, rubocop, brakeman, markdown-link-checker success**. Tip `413463c7` adds docs-only delta on top of that tree; tip CI re-run did not complete on hosted runners at snapshot time.

---

## Section A — Draft and review

| Field | Value |
| --- | --- |
| PR state | **Open** |
| Draft | **Yes** (`isDraft: true`) |
| Mergeable (GitHub) | MERGEABLE |
| Mergeable state | **blocked** (checks / branch protection) |
| Review decision | **REVIEW_REQUIRED** |
| Formal GitHub reviews on PR | **None** (`get_reviews` empty at snapshot) |
| Human Approve (@gktreviewer) | **Not present** |

---

## Section A — Merge readiness (explicit)

**#4450 is NOT merge-ready** at this snapshot.

Gates still required before merge GO (non-exhaustive):

1. **GKT-462** — Railway / Doppler / DNS staging: **Pass**, human **Approve**, and **Mark GO** (not satisfied at snapshot; staging infra not signed off by this audit).
2. **Staging walkthrough** — Human run per [GKT-739](https://linear.app/gkt/issue/GKT-739) procedure on Railway review server; Section B there remains **Pending**.
3. **CI on tip** — Main **CI** matrix for `413463c7` did **not** pass (cancelled/failed run); re-run required for a green tip signal.
4. **CODEOWNERS Approve** — @gktreviewer approval still required (`REVIEW_REQUIRED`).
5. **Draft** — PR remains draft; undraft is a separate Mark decision.

**Prefer [#4410](https://github.com/EBWiki/EBWiki/pull/4410) before #4450** for merge ordering: search stack (`pg_search`, drop Elasticsearch) is independent and should land first; #4450 explicitly excludes `CaseSearch` / search specs owned by #4410.

---

## Section B — RESULT

> **GKT-759 (this ticket):** CI/draft/review snapshot only — **no merge**, **no undraft**, **no staging execution**.

| Field | Value |
| --- | --- |
| GKT-759 deliverable | This file (`artifacts/GKT-759-4450-tip-ci-snapshot.md`) |
| Tip matches `413463c7`? | **Yes** |
| Tip CI (main CI matrix) | **Not green** — run 37365045554 failed (hosted runner acquisition); jobs cancelled |
| Tip CI (E2E + CodeQL) | **Green** on head SHA at snapshot |
| Draft? | **Yes** |
| @gktreviewer Approve? | **No** |
| **Merge-ready?** | **No** — **GKT-462 gated** (staging Pass + Approve + Mark GO still required) |
| GKT-462 (Doppler / Railway / DNS) | **Not GO** at snapshot — prefer **GO** when Mark completes GKT-462; do **not** treat parent GKT-175 as locked; record blockers instead of forcing merge |
| Parent GKT-175 | **Open** — friendly photos epic; this snapshot does not close it |
| Merge #4450 from this ticket? | **No** |
| Merge order note | **Prefer #4410 before #4450** |
| Re-run CI before Approve? | **Yes** — re-trigger CI on `413463c7` (or newer tip) after runner queue clears |
| Reviewer / agent | Cursor Agent (audit snapshot) |
| Date (UTC) | 2026-10-05 |

---

## References

- Draft feature PR: [#4450](https://github.com/EBWiki/EBWiki/pull/4450)
- Search landing PR (merge first): [#4410](https://github.com/EBWiki/EBWiki/pull/4410)
- Staging procedure: `artifacts/GKT-739-staging-walkthrough-checklist.md` (on PR branch at tip)
- Parent epic: [GKT-175](https://linear.app/gkt/issue/GKT-175)
- Staging infra gate: [GKT-462](https://linear.app/gkt/issue/GKT-462)
