# Friendly photo search

EBWiki case pages should show a dignified photo of the person whenever one
exists. The case form already asks editors to look beyond mugshots. This
workflow is a curator-assist finder: it proposes openly licensed portraits
and waits for a human to approve or reject them.

A friendly photo is a family picture, portrait, yearbook image, or other
non-carceral photo. Mugshots, booking photos, inmate-lookup images, and
jail or prison identification photos are excluded or cannot be applied.

Nothing is published automatically. A person always reviews the candidates.

## AI backend

When `OPENAI_API_KEY` or `ANTHROPIC_API_KEY` is set, search uses two AI
layers on top of the same Wikimedia/Openverse allowlist:

1. **Search planner** (`SearchPlanner`) — given a person name plus optional
   city/year, an LLM returns 4–8 name-first queries for Wikimedia Commons
   and Openverse. It does not invent faces or licenses.
2. **Vision classifier** (`VisionClassifier`) — scores each candidate image
   as a friendly portrait vs mugshot/booking before Apply is offered.
   Metadata heuristics (`MugshotClassifier`) still run; either layer can
   hard-block a mugshot.

Without an API key, or when the provider errors, the app **gracefully
degrades** to the deterministic heuristic planner and metadata-only
classification. CI and Playwright keep stubs via `E2E_STUB_WIKIMEDIA=1`
(search fixtures) and never need live AI keys.

| Variable | Purpose |
| --- | --- |
| `OPENAI_API_KEY` | Enable OpenAI planner + vision (`gpt-4o-mini` default) |
| `ANTHROPIC_API_KEY` | Fallback provider (`claude-3-5-haiku-latest` default) |
| `FRIENDLY_PHOTOS_OPENAI_MODEL` | Override OpenAI model |
| `FRIENDLY_PHOTOS_ANTHROPIC_MODEL` | Override Anthropic model |
| `FRIENDLY_PHOTOS_STUB_AI=1` | Deterministic stub AI for unit tests |
| `E2E_STUB_WIKIMEDIA=1` | Stub Wikimedia/Openverse (CI/Playwright only) |

**Review server (Railway):** set `REVIEW_SERVER=1`, leave
`E2E_STUB_WIKIMEDIA` unset (or `0`) so search hits live APIs. Add
`OPENAI_API_KEY` or `ANTHROPIC_API_KEY` in Railway Variables for AI.
Disposable login is seeded by `rake review:seed` on deploy.

### Railway review deploy (ebwiki-friendly-photos-review)

| Item | Value |
| --- | --- |
| URL | https://ebwiki-web-production.up.railway.app/friendly_photos |
| Branch | `cursor/friendly-photos-search-dfb7` |
| Login | `e2e@example.com` / `e2e-password` |
| Live search | `E2E_STUB_WIKIMEDIA=0` (or unset) on `ebwiki-web` |
| AI | `OPENAI_API_KEY` on `ebwiki-web` (falls back to heuristics without it) |

**Redeploy after a git push** (when GitHub webhook is connected):

1. Push to `cursor/friendly-photos-search-dfb7`.
2. Railway project **ebwiki-friendly-photos-review** → service **ebwiki-web** → **Deployments** — confirm a new build for the pushed SHA.

**If auto-deploy stops** (e.g. `connect-service-source` fails with “User does not have access to the repo”):

1. Railway dashboard → **ebwiki-friendly-photos-review** → **ebwiki-web** → **Settings** → **Source**.
2. **Connect GitHub** (or **Reconnect**) as Mark (`mnyon-grandkru`) with access to `EBWiki/EBWiki`.
3. Set branch to `cursor/friendly-photos-search-dfb7`, builder **Dockerfile** = `Dockerfile.review`.
4. **Deploy** (or push an empty commit to re-trigger the webhook).
5. Verify **Variables**: `REVIEW_SERVER=1`, `E2E_STUB_WIKIMEDIA=0`, `OPENAI_API_KEY` set; do not point `DATABASE_URL` at production Heroku.

Cloud Agent MCP cannot re-attach the repo without Mark’s GitHub OAuth on Railway.

### Neon review database (official — not Railway Postgres)

Mark confirmed **Neon** is the review DB. Railway **ebwiki-web** stays the app host;
`DATABASE_URL` should point at Neon (pooled URL for Puma). Do **not** load
`latest.dump` into Railway Postgres.

| Step | Action |
| --- | --- |
| 1 | Create Neon project **`ebwiki-review`** (or branch `review-friendly-photos`) via Neon MCP/CLI once Mark’s auth lands |
| 2 | **Check for existing data** — `SELECT COUNT(*) FROM cases;` — do not wipe without Mark confirming `FORCE=1` |
| 3 | `pg_restore` via **DIRECT** connection (no `-pooler` host). Dump blob: commit `592560514b263c8956d039bdd25c9c8b7fb2a81f` (~69MB, 2020-09-01 Heroku snapshot) |
| 4 | Run `db/dump_compat.sql` (rename `cause_of_death`, add `cases.tsv`, dedupe ids, add PKs) |
| 5 | `bundle exec rails db:migrate` for friendly-photos tables |
| 6 | Set Railway **ebwiki-web** `DATABASE_URL` → Neon **pooled** URL; keep `E2E_STUB_WIKIMEDIA=0`, `OPENAI_API_KEY`, `REVIEW_SERVER=1` |
| 7 | Redeploy ebwiki-web; verify case count + live search on real names |

Script (run when `pg_restore`/`psql` available and Neon DIRECT URL is set):

```bash
NEON_DIRECT_URL='postgres://...direct...' ./scripts/restore_ebwiki_neon_review.sh
# Only if empty DB or Mark approved wipe:
FORCE=1 NEON_DIRECT_URL='...' ./scripts/restore_ebwiki_neon_review.sh
```

**Status (2026-09-06):** Restore **held** — Neon MCP needs Mark’s `org_id` auth
(Ringleader in progress). Dump verified locally at `/tmp/latest.dump`; GitHub raw URL returns 200.

## How to try it

1. Sign in as an editor.
2. Open **Friendly photos** in the header (`/friendly_photos`).
3. Find a case by name, city/state, date, or case id/slug.
4. Open **Review photos**.
5. Click **Search Wikimedia and Openverse**.
6. Approve a non-mugshot candidate with a recorded license, or reject it.
   If there is no usable portrait, the page says **None found**.

Local batch / agent path:

```
bundle exec rake photos:classify_current
bundle exec rake photos:search_friendly CASE=walter-scott
bundle exec rake photos:search_friendly LIMIT=10 FORMAT=json
```

## Source strategy

| Source | What we take | What we refuse |
| --- | --- | --- |
| Wikimedia Commons + English Wikipedia | HTTPS jpeg/png/gif/webp with license metadata | Mugshot/booking/inmate terms, PDF/DjVu scans |
| Openverse (CC0, CC BY, CC BY-SA, PDM) | Flickr/Wikimedia-hosted images with a license URL | Mugshot-farm hosts and booking-database text |
| News sites, social networks, arrest DBs | Nothing. We do not scrape them. | Primary source |

Ranking (higher is better):

1. Portrait / family / yearbook / memorial language
2. News-style stills (bodycam, incident, protest) — kept but downranked
3. Mugshot / booking / jail / inmate language — hard-downranked, cannot apply
4. Known mugshot-farm hosts (`mugshots.com`, `arrests.org`, VineLink, and
   similar) — excluded before save

Each stored candidate keeps `license`, optional `license_url`, author,
source, and the source page. Apply refuses mugshots, missing licenses, and
hosts outside the Wikimedia/Openverse allowlist.

## In the app

Signed-in editors can:

1. Open **Friendly photos** in the header, or open a case and choose
   **Search Wikimedia for a friendly photo** on the edit form.
2. Search by name, location, date, or id, and filter missing / mugshot /
   unclassified / portrait cases.
3. Run a Wikimedia + Openverse search for that person.
4. Reject anything that still looks like a mugshot.
5. Apply a reviewed portrait, or upload a better file on the case edit form.
6. Mark the current photo as **Portrait**, **Mugshot**, or **Other**.

## Sample outputs

Against the Playwright seed (`e2e-missing-photo` / Jordan Doe) with
`E2E_STUB_WIKIMEDIA=1`:

- **E2E family portrait** (Wikimedia, CC BY-SA 4.0) — apply allowed
- **E2E openverse portrait** (Openverse/Flickr, CC BY 4.0 + license URL) —
  apply allowed
- **E2E booking mugshot** — shown as flagged, apply hidden
- Searching a person with only booking-photo hits shows **None found**

Live Wikimedia/Openverse (2026-09-05, no attach):

- **Walter Scott** (name only) hits Sir Walter Scott portraits on Commons.
  That is expected name collision. A person must reject the wrong face.
- **Killing of Walter Scott** exists on Wikipedia but has **no page image**.
  Commons + city still returns unrelated scans. Honest result: **none found**
  for a verified portrait of that subject.
- **George Floyd portrait** on Commons returns licensed stills (CC BY / BY-SA),
  including murals and protest photos. Those are review candidates, not
  auto-attach. Protest/incident language is downranked vs family/portrait.
- Queries also try `Killing of {name}` and `Shooting of {name}`. Commons
  drops mugshot/booking/inmate terms plus PDF/DjVu scans.

Do not attach anything until a person reviews it. Never invent a face.

## Agent routine

Use this when an agent should walk the database and propose replacements
instead of clicking through the UI.

1. Load cases that still need a better photo: `Case.needing_friendly_photo`
2. Optionally classify current filenames: `rake photos:classify_current`
3. Search: `rake photos:search_friendly CASE=walter-scott`
4. Drop any row whose `likely_mugshot` flag is true.
5. Present remaining portraits with license, license URL, author, and
   source page. Do not apply from an agent run.
6. After a person accepts a candidate, apply it in the app.

## End-to-end tests

Capybara covers the editor UI in `spec/features/friendly_photos_spec.rb`
and runs on every PR. Playwright is a path-filtered GitHub Actions
workflow. See `e2e/README.md` and `docs/E2E_FRIENDLY_PHOTOS.md`.

```
bundle exec rake e2e:seed_friendly_photos
npm install
npx playwright install chromium
npm run e2e:smoke
```

## Rate limits (live search)

| API | Notes |
| --- | --- |
| Wikimedia Commons / Wikipedia | Public API; descriptive User-Agent. ~200 req/s per IP typical; 8s timeout per call. |
| Openverse | Public API; may return 429 if hammered — retry later. |
| OpenAI / Anthropic | Billed per token/image; vision runs once per new candidate image. |

## Rules

- Search only Wikimedia Commons, English Wikipedia, and Openverse.
- Do not scrape social networks, news sites, or booking-photo databases.
- Do not invent faces or licenses.
- Do not apply a candidate without a human review.
- Prefer a family or community portrait over an incident or protest photo.
- Keep the license and source page with the candidate.
- If no friendly photo is found, leave the case unchanged.
