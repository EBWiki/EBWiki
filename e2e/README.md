# Friendly photo end-to-end tests

These Playwright tests drive the Rails test server in a real browser. They
confirm the editor workflow for finding non-mugshot portraits and call out
gaps that unit tests cannot see.

## What is covered

- Guests are redirected to login
- Signed-in editors see **Friendly photos** and the cases that still need a
  better photo
- Filters for missing, mugshot, and portrait cases
- Case pages only offer **Find a friendly photo** when one is needed
- Classifying the current photo
- Rejecting a candidate and refusing to apply a mugshot
- Applying a reviewed portrait through the stub
- Searching Wikimedia through the `E2E_STUB_WIKIMEDIA=1` stub
- Mobile navbar: the Friendly photos link is behind the hamburger

Each test resets fixtures via `POST /e2e/friendly_photos/reset` so classify
and apply do not leak into later cases. That route exists only when the
Wikimedia stub is enabled.

## What is stubbed

Live Wikimedia HTTP and CarrierWave downloads are stubbed when
`E2E_STUB_WIKIMEDIA=1`. That keeps CI deterministic. It also means a true
remote apply (ImageMagick + upload storage) is not exercised here.

## Running locally

```
cp config/database.example.yml config/database.yml
bundle exec rails db:prepare
bundle exec rake e2e:seed_friendly_photos
E2E_STUB_WIKIMEDIA=1 RAILS_ENV=test bundle exec rails server -b 127.0.0.1 -p 3001
```

In another terminal:

```
npm install
npx playwright install chromium
E2E_BASE_URL=http://127.0.0.1:3001 npm run e2e
```

Or let Playwright start the server:

```
bundle exec rake e2e:seed_friendly_photos
npm run e2e
```

Capybara covers the same editor flows inside `spec/features/friendly_photos_spec.rb`
and runs with the existing RSpec job.

## GitHub Actions

Playwright lives in `.github/workflows/e2e.yml`, not the main CI workflow.
That keeps Action minutes under control:

| Trigger | What runs |
| --- | --- |
| Every PR | Capybara feature specs via **CI / rspec** |
| PR that touches photo UI, e2e fixtures, or the e2e workflow | Desktop Chromium smoke (`npm run e2e:smoke`) |
| Monday 06:00 UTC on the default branch | Full suite, including Pixel 5 |
| Actions → E2E → Run workflow | Smoke or full, on demand |
| Unrelated file changes or superseded pushes | Skipped or cancelled |

The e2e job does not start Elasticsearch. Searchkick callbacks are disabled
when `E2E_STUB_WIKIMEDIA=1`. Gems, npm, and Chromium are cached. Failed
runs keep the Playwright report for 3 days.

To force a browser pass on a PR that would otherwise skip it, use
**Run workflow** from the Actions tab and choose this branch.
