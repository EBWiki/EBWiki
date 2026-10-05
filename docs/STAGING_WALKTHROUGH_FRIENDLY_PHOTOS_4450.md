# Staging walkthrough checklist — friendly photos (#4450)

Manual QA on the **Railway review server** for draft PR
[#4450](https://github.com/EBWiki/EBWiki/pull/4450) (`cursor/friendly-photos-clean-9ad4`).
Parent epic **GKT-175** stays open; **Official / mugshot** cases remain in scope —
this checklist proves editors cannot **apply** `likely_mugshot` candidates.

**Related docs PR:** [#4460](https://github.com/EBWiki/EBWiki/pull/4460) updates
`docs/FRIENDLY_PHOTOS.md` so Railway builds `cursor/friendly-photos-clean-9ad4`
instead of the retired `cursor/friendly-photos-search-dfb7` branch. Merge or cherry-pick
that doc change before relying on deploy instructions in `FRIENDLY_PHOTOS.md`.

**Idempotency:** `GKT-175:auto:4450-staging-walkthrough-checklist`  
**Linear:** GKT-681 (checklist only — no Linear updates from agents)

## Preconditions

| Item | Expected |
| --- | --- |
| Deploy branch | `cursor/friendly-photos-clean-9ad4` at the same SHA as this checklist |
| Review URL | `https://ebwiki-web-production.up.railway.app` (paths below are relative) |
| Editor login | `e2e@example.com` / `e2e-password` (seeded by `rake review:seed` on review deploy) |
| Live search | `E2E_STUB_WIKIMEDIA=0`, `REVIEW_SERVER=1`, `OPENAI_API_KEY` set on **ebwiki-web** |
| Fixture case (optional) | Slug `e2e-missing-photo` — Playwright seed includes a friendly + `likely_mugshot` pair |

Use **desktop Chrome** (fixed header and stacked cards make apply/reject awkward on phone).

**Do not** apply Commons photos to real production cases during this walkthrough unless
Mark explicitly asks. Prefer the E2E fixture case or a throwaway case.

---

## Checklist

Record **Pass / Fail** and a one-line note for each step.

### 1. Sign in

- [ ] Open `/users/sign_in`.
- [ ] Log in as `e2e@example.com` / `e2e-password`.
- [ ] **Pass:** Header shows the signed-in email; no redirect loop.

### 2. Index — filter “needs photo”

- [ ] Open `/friendly_photos`.
- [ ] **Pass:** Page title **Profile pictures**; nav link **Profile pictures** (`data-testid="friendly-photos-nav"`).
- [ ] Click pill **Needs a profile picture** (`filter=needs_photo`, `data-testid="filter-needs_photo"`).
- [ ] **Pass:** URL includes `filter=needs_photo`; table lists cases that still need a dignified photo (`data-testid="friendly-photos-table"`).
- [ ] **Pass:** Rows with **Photo type** **Profile picture** (`portrait`) are not listed under this filter.

### 3. Find a case (search)

- [ ] On `/friendly_photos`, use **Find case** (`data-testid="case-search-form"`):
  - Either search **Case ID** `e2e-missing-photo`, **or**
  - Pick any row from step 2 and note its slug.
- [ ] **Pass:** Target row visible; **Review photos** button present (`data-testid="find-photos-<slug>"`).

### 4. Review page — search Wikimedia and Openverse

- [ ] Click **Review photos** for the chosen case (`/friendly_photos/<slug>`).
- [ ] **Pass:** **Search backend:** shows **live Wikimedia + Openverse** (not “stubbed”).
- [ ] Click **Search Wikimedia and Openverse** (`data-testid="search-wikimedia"`); accept the confirm dialog.
- [ ] **Pass:** Flash or **Last search** line mentions planner/vision when AI is configured; candidate cards appear **or** honest **None found** if every hit is unsuitable.

### 5. Mugshot candidate — apply refused in UI

- [ ] On the review page, locate a card with **`data-candidate-kind="mugshot"`** and/or
  **`data-testid="mugshot-flag"`** text **This is not a healthy profile picture**.
  - On fixture case `e2e-missing-photo`, seed data includes `likely_mugshot: true` **Jordan Doe institutional photo**.
- [ ] **Pass:** That card has **no** **Use this photo** button (`data-testid="apply-photo"`).
- [ ] **Pass:** A friendly candidate (if present) still has exactly one **Use this photo** when vision verified.

### 6. Reject mugshot candidate

- [ ] On the mugshot card, click **Reject** (`data-testid="reject-photo"`).
- [ ] **Pass:** Flash **Rejected that candidate**; card status shows rejected or apply control remains absent.

### 7. Apply blocked for `likely_mugshot` (server)

UI hiding **Use this photo** is necessary but not sufficient — confirm the controller/service refusal.

- [ ] Note `photo_candidate_id` for the mugshot row (HTML `data-testid="candidate-<id>"` or admin audit).
- [ ] While signed in, POST apply for that id (browser devtools or curl with session cookie):

```bash
# Replace SLUG, ID, and Cookie after signing in via the browser.
curl -sS -o /tmp/apply-mugshot.html -w '%{http_code}\n' \
  -X POST "https://ebwiki-web-production.up.railway.app/friendly_photos/SLUG/apply" \
  -H 'Cookie: _ebwiki_session=...' \
  -d "photo_candidate_id=ID&authenticity_token=..."
```

- [ ] **Pass:** Redirect back to review with error flash equivalent to
  **This is not a healthy profile picture and cannot be applied.** (see
  `FriendlyPhotos::ApplyCandidate` when `candidate.likely_mugshot?`).
- [ ] **Pass:** Case avatar unchanged; candidate not `accepted`.

### 8. Manual upload + `avatar_kind`

- [ ] From review, click **Edit case** or open `/cases/<slug>/edit`.
- [ ] **Pass:** **What kind of photo is this?** shows avatar kind options; link **Search for a profile picture** (`data-testid="edit-search-friendly-photo"`).
- [ ] Upload a small test image via **Browse** / `avatar` file field; set kind to **Profile picture** or **Needs a healthier photo** as appropriate; save the case form.
- [ ] **Pass:** Save succeeds; returning to `/friendly_photos/<slug>` shows updated **Photo type** label.

### 9. Case show — find-photo link

- [ ] Open public case show `/cases/<slug>`.
- [ ] **Pass:** When the case still needs a profile picture, link **Find a profile picture**
  (`data-testid="find-friendly-photo"`) points to `/friendly_photos/<slug>`.
- [ ] After marking **Profile picture** and attaching a suitable photo, **Pass:** find-photo link is absent.

---

## Sign-off

| Field | Value |
| --- | --- |
| Reviewer | |
| Railway deploy SHA | |
| Branch | `cursor/friendly-photos-clean-9ad4` |
| Date (UTC) | |
| Mugshot apply refused (steps 5–7) | Pass / Fail |
| Overall | Pass / Fail |

## Automated parity (local)

These specs encode the same mugshot/refusal behavior (CI uses stubs; not a substitute for step 7 on Railway):

```bash
bundle exec rspec spec/features/friendly_photos_spec.rb \
  spec/services/friendly_photos/apply_candidate_spec.rb \
  spec/requests/friendly_photos_spec.rb
```

## References

- Product/docs: `docs/FRIENDLY_PHOTOS.md`, `docs/E2E_FRIENDLY_PHOTOS.md`
- Playwright flow: `e2e/friendly-photos.spec.ts`
- Draft feature PR: [#4450](https://github.com/EBWiki/EBWiki/pull/4450)
