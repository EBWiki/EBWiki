# End-to-end tests

Playwright covers the browser flows that Capybara `rack_test` cannot: Turbo, Stimulus, Trix, and Bootstrap JS.

**Do not install Playwright or Chromium on a local laptop.** The suite is meant to run in GitHub Actions or a Cursor Cloud / web agent container, where Node and Chrome already exist.

## What it expects

- A running EBWiki server at `BASE_URL` (default `http://127.0.0.1:3000`)
- Seeded development data from `db/seeds.rb`
  - Admin login: `jdoe@example.com` / `password`
  - Case title `Sven Svensson` (slug `/cases/sven-svensson`)

## Run in a Cloud / web agent

The agent container already has Node and Chrome. From the repo root, with Rails up:

```bash
npm ci
PW_CHANNEL=chrome bin/e2e
```

`playwright.config.js` also selects system Chrome automatically when `/usr/bin/google-chrome` is present and `CI` is unset.

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
| `E2E_EMAIL` | `jdoe@example.com` | Seeded login |
| `E2E_PASSWORD` | `password` | Seeded login |
| `PW_CHANNEL` | system Chrome when available | `chrome` uses the host browser; unset in CI |
| `SKIP_GEOCODE` | unset | Set in CI so seeds do not call an external geocoder |
