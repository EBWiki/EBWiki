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
- Searching Wikimedia through the `E2E_STUB_WIKIMEDIA=1` stub
- Mobile navbar: the Friendly photos link is behind the hamburger

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
