# GKT-739 — Staging walkthrough checklist (friendly photo finder, #4450)

Written procedure for parent **GKT-175**. Turns the **GKT-735** 10-case sample pack into a human-run Railway staging checklist. This spike is **audit-only**; it does not close GKT-175 and does **not** merge or undraft [#4450](https://github.com/EBWiki/EBWiki/pull/4450).

| Field | Value |
| --- | --- |
| Landing PR | [#4450](https://github.com/EBWiki/EBWiki/pull/4450) |
| Tip SHA (reference) | `3e626501ebb2a35413db47f3dbe475090b5b93bd` |
| Branch | `cursor/friendly-photos-clean-9ad4` |
| Idempotency | `GKT-175:auto:staging-walkthrough-checklist-4450-3e626501` |
| Linear | [GKT-739](https://linear.app/gkt/issue/GKT-739) |
| Companion doc | `docs/STAGING_WALKTHROUGH_FRIENDLY_PHOTOS_4450.md` (global UI steps 1–9) |

---

## Section A — Assumptions and pass/fail bar (GKT-735 aligned)

### Assumptions

1. **Scope:** Draft PR #4450 only. Production Heroku is out of scope for this walkthrough.
2. **Mugshots on cases stay:** Cases that already have an **Official / mugshot** (`avatar_kind: mugshot`) **keep** that classification and existing case avatar on `/cases/<slug>` unless a human explicitly changes photo type during QA. The finder must not silently replace mugshots via search.
3. **Candidates, not case files:** GKT-735 sample pack ran **live search with zero attach**. Staging QA must **not** apply Commons/Openverse photos to the nine real EBWiki subjects unless Mark explicitly asks. Use **`e2e-missing-photo`** (seeded fixture) for apply/reject/server POST proofs.
4. **Live review server:** Staging means Railway **ebwiki-friendly-photos-review** → **ebwiki-web** with `E2E_STUB_WIKIMEDIA=0`, `REVIEW_SERVER=1`, and `OPENAI_API_KEY` set (see `docs/FRIENDLY_PHOTOS.md`). CI stubs are not sufficient for sign-off.
5. **Infrastructure gate:** Full staging sign-off assumes **GKT-462** (Doppler / Railway / DNS) is **GO**. Until Mark confirms GKT-462, treat deploy SHA, secrets, and custom DNS as **unverified** even if the default Railway URL responds.
6. **Browser:** Desktop Chrome. Mobile nav hides **Profile pictures** behind the hamburger; apply/reject are awkward on phone (see `docs/E2E_FRIENDLY_PHOTOS.md`).

### Pass/fail bar (same spirit as GKT-735 sample pack)

A staging run **passes** only if **all** of the following hold:

| # | Bar | Pass criterion |
| --- | --- | --- |
| P1 | **Deploy fidelity** | Railway deployment SHA equals PR #4450 tip `3e626501` (or newer tip Mark names for the run). Branch source is `cursor/friendly-photos-clean-9ad4`, not retired `cursor/friendly-photos-search-dfb7`. |
| P2 | **Auth + editor UI** | Sign-in works; `/friendly_photos` loads **Profile pictures** index, filters, and case search (global steps 1–3 in companion doc). |
| P3 | **Live search** | Review page shows **live Wikimedia + Openverse** (not stubbed). **Search Wikimedia and Openverse** returns candidates or honest **None found**; planner/vision badges appear when AI ran. |
| P4 | **`likely_mugshot` blocked** | For at least one `likely_mugshot` candidate (fixture **Jordan Doe institutional photo** on `e2e-missing-photo`, or a live flagged card): no **Use this photo** in UI; **Reject** works; server POST `/friendly_photos/<slug>/apply` returns error flash *This is not a healthy profile picture and cannot be applied.*; case avatar unchanged (global steps 5–7). |
| P5 | **Mugshot cases preserved** | For real cases in the sample pack that still carry mugshot/booking avatars: case show still displays the existing photo; **Photo type** remains mugshot/official until a human edits it. Search must not auto-apply. |
| P6 | **Per-case sample pack** | For each of the ten slugs below: reviewer completes the evidence row (search ran, mugshot flags sane, honest outcome documented). **No attach** on real cases. |
| P7 | **No false “staging live” claim** | Reviewer recorded GKT-462 status and deploy SHA in Section B. If GKT-462 is not GO or SHA mismatches, overall result is **Fail / blocked**, not Pass. |

**Fail** if any P1–P7 fails, or if a mugshot candidate can be applied via UI or POST.

---

## Section B — RESULT

> **GKT-739 (this ticket):** procedure document only — staging walkthrough **not executed** by the agent that authored this file.
>
> **Human staging run:** fill the table below after completing Sections C–E.

| Field | Value |
| --- | --- |
| GKT-739 deliverable | Procedure written (`artifacts/GKT-739-staging-walkthrough-checklist.md`) |
| Staging walkthrough executed? | **No** (awaiting human + GKT-462 GO) |
| GKT-462 (Doppler / Railway / DNS) | **Not verified by agent** — Mark must set **GO / NO-GO** |
| Railway URL reachable (agent smoke, 2026-10-05 UTC) | `GET /` → **200**; `GET /friendly_photos` → **302** to login (guest gate only). **Does not** prove deploy SHA, secrets, or GKT-462 GO. |
| Deploy SHA on Railway | |
| Matches `3e626501`? | |
| Overall staging result | **Pending** / Pass / Fail |
| Reviewer | |
| Date (UTC) | |
| Notes | |

---

## Section C — Preconditions checklist

Complete **before** Section E per-case work. Check each box; record blockers in Section B.

### C.1 GKT-462 gate (required for “staging GO”)

| Check | Pass | Notes |
| --- | --- | --- |
| GKT-462 marked **GO** by Mark (Doppler secrets synced, Railway source connected, DNS if used) | ☐ | If **NO-GO**, stop after documenting blockers; do not claim staging sign-off. |
| Railway **ebwiki-friendly-photos-review** → **ebwiki-web** → **Settings** → **Source** branch = `cursor/friendly-photos-clean-9ad4` | ☐ | |
| Latest deployment SHA = #4450 tip (see Section A P1) | ☐ | Dashboard → Deployments |
| Variables: `REVIEW_SERVER=1`, `E2E_STUB_WIKIMEDIA=0`, `OPENAI_API_KEY` set | ☐ | |
| `DATABASE_URL` → Neon review (~4033 cases), not production Heroku | ☐ | |
| `rake review:seed` / `review:deploy_prepare` completed on deploy (editor login exists) | ☐ | |

### C.2 URL and auth

| Item | Expected |
| --- | --- |
| Base URL | `https://ebwiki-web-production.up.railway.app` |
| Sign-in | `/users/sign_in` |
| Editor login | `e2e@example.com` / `e2e-password` |
| Friendly photos index | `/friendly_photos` |

### C.3 Global workflow (once per run)

Run **`docs/STAGING_WALKTHROUGH_FRIENDLY_PHOTOS_4450.md`** steps **1–9** on desktop Chrome. Record Pass/Fail in that doc’s sign-off table. Step **7** (curl POST apply for `likely_mugshot`) is **mandatory** for P4.

---

## Section D — Step-by-step order (Railway)

1. **Preconditions** — Section C; abort or mark **blocked** if GKT-462 is not GO.
2. **Global checklist** — Steps 1–9 in `docs/STAGING_WALKTHROUGH_FRIENDLY_PHOTOS_4450.md` (sign-in through case-show link).
3. **Fixture proof (required)** — On `e2e-missing-photo`, confirm seeded **likely_mugshot** candidate blocked (P4). Safe place for Reject + POST apply test.
4. **Sample pack (required)** — For each slug in Section E: open `/friendly_photos/<slug>`, run **Search Wikimedia and Openverse**, capture evidence **without applying** on real cases.
5. **Mugshot preservation spot-check** — On real cases with booking photos, open `/cases/<slug>` and confirm existing avatar unchanged after search.
6. **Section B RESULT** — Record SHA, GKT-462 status, overall Pass/Fail.

---

## Section E — Per-case evidence capture (GKT-735 sample pack)

**Instructions per row:**

1. Open `/friendly_photos/<slug>` (or find via index search).
2. Confirm **Search backend:** **live Wikimedia + Openverse**.
3. Run search; wait for candidates or **None found**.
4. Note any card with **`data-candidate-kind="mugshot"`** / **`data-testid="mugshot-flag"`** — must have **no** apply button.
5. On **`/cases/<slug>`**, confirm mugshot/booking photo **unchanged** after search (real cases only).
6. Do **not** click **Use this photo** on real subjects.

**GKT-735 reference expectations** (2026-09-06 metadata pass; live staging may differ — record what you see):

| Case slug | GKT-735 honest-result hint (reference only) |
| --- | --- |
| `e2e-missing-photo` | Fixture: friendly + **likely_mugshot** pair; use for P4 UI/POST |
| `walter-scott` | Homonym risk (Sir Walter Scott); expect **None found** for EBWiki subject unless human rejects wrong faces |
| `george-floyd` | Candidates likely (murals/memorials); high wrong-context review |
| `breonna-taylor` | Candidates likely; reject wrong faces / arrest-language |
| `eric-garner` | Candidates likely; protest crowd wrong-face risk |
| `tamir-rice` | Candidates mixed; memorial vs unrelated protest stills |
| `sandra-bland` | Candidates likely; jail-building hits should reject |
| `philando-castile` | Live search required — document hits and mugshot flags |
| `freddie-gray` | Live search required — document hits and mugshot flags |
| `michael-brown` | Live search required — document hits and mugshot flags |

### Evidence table (human fill)

| # | Slug | Search live (Y/N) | Candidates or None found | `likely_mugshot` cards blocked (Y/N) | Case mugshot/avatar unchanged (Y/N) | Wrong-face / homonym notes | Pass / Fail | Evidence (screenshot / URL / one line) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `e2e-missing-photo` | | | | n/a (fixture) | | | |
| 2 | `walter-scott` | | | | | | | |
| 3 | `george-floyd` | | | | | | | |
| 4 | `breonna-taylor` | | | | | | | |
| 5 | `eric-garner` | | | | | | | |
| 6 | `tamir-rice` | | | | | | | |
| 7 | `sandra-bland` | | | | | | | |
| 8 | `philando-castile` | | | | | | | |
| 9 | `freddie-gray` | | | | | | | |
| 10 | `michael-brown` | | | | | | | |

**Sample pack pass:** all ten rows **Pass**, plus Section D step 3 (fixture P4) **Pass**, plus global steps 5–7 **Pass**.

---

## Section F — When to request @gktreviewer **Approve** vs wait

### Request **Approve** on #4450 when

- GKT-462 is **GO** and documented in Section B.
- Railway deploy SHA matches the agreed #4450 tip (default `3e626501` or newer tip Mark names).
- Global checklist steps 1–9 **Pass**, including server-side mugshot apply refusal (step 7).
- Section E: all ten sample-pack rows **Pass**; fixture `e2e-missing-photo` proves P4.
- No open blocker on parent GKT-175 items Mark still owns (merge GO, production deploy, follower email gap, etc.) — Approve means **code review**, not production ship.

### **Wait** (do not ask for Approve yet) when

- GKT-462 is **NO-GO** or Doppler/Railway/DNS not confirmed.
- Deploy SHA ≠ PR tip, or Railway still tracks retired branch `cursor/friendly-photos-search-dfb7`.
- Any **Fail** on P4 (mugshot apply possible) or missing live search on review server.
- Sample pack incomplete or real-case attach happened during QA.
- CI on the requested tip is red (check PR #4450 checks).

### Explicit non-actions (GKT-739 / GKT-175)

- **Do not** merge #4450 as part of this checklist spike.
- **Do not** undraft #4450 unless Mark opens a separate merge-GO ticket.
- **Prefer** staging **GO** (GKT-462 complete, SHA pinned) before Approve, but this document is useful even when staging is **blocked** — record **Pending** in Section B rather than locking the parent epic.

---

## References

- Product: `docs/FRIENDLY_PHOTOS.md` (review server, sample pack notes)
- Global UI steps: `docs/STAGING_WALKTHROUGH_FRIENDLY_PHOTOS_4450.md`
- E2E parity: `docs/E2E_FRIENDLY_PHOTOS.md`, `e2e/friendly-photos.spec.ts`
- Apply refusal: `FriendlyPhotos::ApplyCandidate` (`likely_mugshot?`)
- Draft feature PR: [#4450](https://github.com/EBWiki/EBWiki/pull/4450)
