# Friendly photo search

EBWiki case pages should show a dignified photo of the person whenever one
exists. The case form already asks editors to look beyond mugshots. This
workflow is a curator-assist finder: it proposes openly licensed portraits
and waits for a human to approve or reject them.

A friendly photo is a family picture, portrait, yearbook image, or other
non-carceral photo. Mugshots, booking photos, inmate-lookup images, and
jail or prison identification photos are excluded or cannot be applied.

Nothing is published automatically. A person always reviews the candidates.

## Where we search (locked)

Friendly photo search queries **only** these sources. This scope is fixed —
not an open design question (GKT-182 holds):

| Source | Role |
| --- | --- |
| **Wikimedia Commons** | Primary image repository |
| **English Wikipedia** | Article lead images and linked Commons files |
| **Openverse** | CC0, CC BY, CC BY-SA, and PDM images (Flickr/Wikimedia hosts) |

We do **not** scrape news sites, social networks, arrest databases, or
mugshot-farm hosts. Those hosts are blocked before save.

## AI backend (review path)

When `OPENAI_API_KEY` or `ANTHROPIC_API_KEY` is set (required on the review
server), search uses two AI layers on the allowlist above:

1. **Search planner** (`SearchPlanner`) — given a person name plus optional
   city/year, the LLM returns 4–8 name-first queries for Wikimedia Commons
   and Openverse. It does not invent faces or licenses.
2. **Vision classifier** (`VisionClassifier`) — scores each candidate image
   as a friendly portrait vs mugshot/booking before Apply is offered.
   Metadata heuristics (`MugshotClassifier`) still run; either layer can
   hard-block a mugshot.

With an API key configured, planner and vision **must** succeed. There is no
silent fallback to heuristic-only search on review. If the provider errors,
the search surfaces an error and the editor can retry.

Without an API key (local dev only), the app uses the deterministic
`HeuristicPlanner` and metadata-only classification. CI unit tests use
`FRIENDLY_PHOTOS_STUB_AI=1` for deterministic stub AI.

| Variable | Purpose |
| --- | --- |
| `OPENAI_API_KEY` | Enable OpenAI planner + vision (`gpt-4o-mini` default) |
| `ANTHROPIC_API_KEY` | Alternate provider (`claude-3-5-haiku-latest` default) |
| `FRIENDLY_PHOTOS_OPENAI_MODEL` | Override OpenAI model |
| `FRIENDLY_PHOTOS_ANTHROPIC_MODEL` | Override Anthropic model |
| `FRIENDLY_PHOTOS_STUB_AI=1` | Deterministic stub AI for unit tests only |
| `E2E_STUB_WIKIMEDIA=1` | Stub Wikimedia/Openverse HTTP (CI/Playwright only) |

**Default:** live Wikimedia + Openverse. Stubs are opt-in for CI/E2E only
(`E2E_STUB_WIKIMEDIA=1`). Review servers must leave it unset or `0`.

### Review server (Railway)

| Item | Value |
| --- | --- |
| URL | https://ebwiki-web-production.up.railway.app/friendly_photos |
| Branch | `cursor/friendly-photos-search-dfb7` |
| Login | `e2e@example.com` / `e2e-password` |
| Live search | `E2E_STUB_WIKIMEDIA=0` on `ebwiki-web` (variable is present; live APIs) |
| AI | `OPENAI_API_KEY` present on `ebwiki-web` — SearchPlanner + VisionClassifier |
| Database | **Neon** (official review DB — not Railway Postgres) |

Set `REVIEW_SERVER=1`. Disposable login is seeded by `rake review:seed` on
deploy.

**Redeploy after a git push** (when GitHub webhook is connected):

1. Push to `cursor/friendly-photos-search-dfb7`.
2. Railway project **ebwiki-friendly-photos-review** → service **ebwiki-web** → **Deployments** — confirm a new build for the pushed SHA.

**If auto-deploy stops** (e.g. `connect-service-source` fails with “User does not have access to the repo”):

1. Railway dashboard → **ebwiki-friendly-photos-review** → **ebwiki-web** → **Settings** → **Source**.
2. **Connect GitHub** (or **Reconnect**) as Mark (`mnyon-grandkru`) with access to `EBWiki/EBWiki`.
3. Set branch to `cursor/friendly-photos-search-dfb7`, builder **Dockerfile** = `Dockerfile.review`.
4. **Deploy** (or push an empty commit to re-trigger the webhook).
5. Verify **Variables**: `REVIEW_SERVER=1`, `E2E_STUB_WIKIMEDIA=0`, `OPENAI_API_KEY` set; point `DATABASE_URL` at Neon (pooled URL), not production Heroku.

### Neon review database

Mark confirmed **Neon** is the review DB. Railway **ebwiki-web** stays the
app host; `DATABASE_URL` should point at Neon (pooled URL for Puma). Do
**not** load `latest.dump` into Railway Postgres.

| Step | Action |
| --- | --- |
| 1 | Create Neon project **`ebwiki-review`** (or branch `review-friendly-photos`) |
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

**Status (2026-09-06):** Restore **held** pending Neon MCP auth. Dump
verified locally; GitHub raw URL returns 200.

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

## Source policy

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

## Live search notes

Verified on the Railway review server (2026-09-06):

- Review page shows **live Wikimedia + Openverse** and **AI: openai (gpt-4o-mini)**.
- `E2E_STUB_WIKIMEDIA=0` and `OPENAI_API_KEY` are set on `ebwiki-web`.
- Search on seeded cases returns real API hits; mugshots are flagged and
  cannot be applied without human approval.

### Real-case sample pack (2026-09-06, no attach)

Live Commons + English Wikipedia + Openverse only. Heuristic query list
(name, name+city, name+year, `{name} portrait`, `{name} family photo`,
`Killing of {name}`, `Shooting of {name}`). Metadata mugshot flags only
(Railway vision would also run when the key is set). Nothing applied.
Never invent a face.

| Case | Hits | Friendly (review) | Mugshot rejects | Wrong-face risk | Honest result |
| --- | ---: | ---: | ---: | ---: | --- |
| Walter Scott (North Charleston, 2015) | 36 | 35 | 0 | 27+ (novelist/statue) | **None found** for the EBWiki subject. Wikipedia default is Sir Walter Scott. A person must reject the novelist. |
| George Floyd (Minneapolis, 2020) | 40 | 38 | 0 | murals/protest mix | **Candidates found** — licensed murals, memorials, protest stills. Review; downrank incident photos. Not a family portrait by default. |
| Breonna Taylor (Louisville, 2020) | 22 | 19 | 1 (arrest-language video) | 8 (incl. unrelated people) | **Candidates found** — memorials/artwork/protest. Human must pick a dignified still and reject wrong faces. |
| Eric Garner (New York, 2014) | 24 | 22 | 0 | 16 (crowd/protest) | **Candidates found** — RIP/cover/protest photos. High wrong-face in protest crowds. |
| Tamir Rice (Cleveland, 2014) | 13 | 12 | 0 | 9 (Ferguson protests) | **Candidates found** — memorial icons plus many unrelated protest stills. Wikipedia page often has **no** lead image. |
| Sandra Bland (Prairie View, 2015) | 23 | 18 | 3 (jail building) | 12 | **Candidates found** — campus memorials and marches. Jail-building photos correctly rejected. |

CI stub (`e2e-missing-photo` / Jordan Doe, `E2E_STUB_WIKIMEDIA=1`) still
shows family portrait vs booking mugshot for Playwright only.

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

CI and Playwright set `E2E_STUB_WIKIMEDIA=1` so tests never hit live APIs.
That stub is **not** used on the review server.

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
