# End-to-end tests

Playwright covers the browser flows that Capybara `rack_test` cannot: Turbo, Stimulus, Trix, and Bootstrap JS.

**Do not install Playwright or Chromium on a local laptop.** The suite is meant to run in GitHub Actions or a Cursor Cloud / web agent container, where Node and Chrome already exist.

## What it covers

Each use case has a happy path plus two primary errors (auth, validation, empty results, or not found).

| Use case | Spec |
| --- | --- |
| Sign in / sign up / sign out / password reset | `e2e/auth.spec.js` |
| Browse, view, create, edit, history, followers, follow | `e2e/cases.spec.js` |
| Comment on a case | `e2e/comments.spec.js` |
| Search | `e2e/search.spec.js` |
| Agencies (list, show, create, edit) | `e2e/agencies.spec.js` |
| Organizations | `e2e/organizations.spec.js` |
| Maps | `e2e/maps.spec.js` |
| Profile show / edit | `e2e/users.spec.js` |
| Mailbox, compose, reply, trash | `e2e/mailbox.spec.js` |
| Static pages | `e2e/static.spec.js` |
| Admin dashboard and agency create | `e2e/admin.spec.js` |

## What it expects

- A running EBWiki server at `BASE_URL` (default `http://127.0.0.1:3000`)
- Seeded development data from `db/seeds.rb`
  - Admin: `jdoe@example.com` / `password`
  - Member: `jsmith@example.com` / `password`
  - Case titles such as `Sven Svensson`, `Janez Novak`, `Kari Holm`
  - Agencies `City of Houston Police Department` and `City of Beaumont Police Department`
- `SKIP_GEOCODE=1` on the Rails process so create/update does not call an external geocoder

## Run in a Cloud / web agent

The agent container already has Node and Chrome. From the repo root, with Rails up:

```bash
npm ci
PW_CHANNEL=chrome bin/e2e
```

`playwright.config.js` also selects system Chrome automatically when `/usr/bin/google-chrome` is present and `CI` is unset. Failure video is recorded only in CI so a Cloud Agent does not need Playwright's ffmpeg binary.

## Run in GitHub Actions

The `e2e` job in `.github/workflows/ci.yml` boots Postgres, Redis, and Rails, seeds the database, installs Playwright's Chromium in that job, and runs the suite. Failure artifacts (trace, screenshot, HTML report) are uploaded.

## Optional local run

Only if you already have Node and a browser and still want to run it yourself:

```bash
npm ci
npx playwright install chromium   # downloads a browser; skip this on older machines
BASE_URL=http://127.0.0.1:3000 bin/e2e
```

## Environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `BASE_URL` | `http://127.0.0.1:3000` | App under test |
| `E2E_EMAIL` | `jdoe@example.com` | Seeded admin login |
| `E2E_PASSWORD` | `password` | Seeded admin login |
| `E2E_MEMBER_EMAIL` | `jsmith@example.com` | Seeded non-admin login |
| `E2E_MEMBER_PASSWORD` | `password` | Seeded non-admin login |
| `PW_CHANNEL` | system Chrome when available | `chrome` uses the host browser; unset in CI |
| `SKIP_GEOCODE` | unset | Set on the Rails server so writes do not call an external geocoder |
