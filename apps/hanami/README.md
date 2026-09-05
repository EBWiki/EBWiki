# EBWiki Hanami public site

Hanami 3 reads and writes the existing Postgres schema. Rails still owns
mail delivery, CarrierWave/S3 object keys, and production cutover.

| Method | Path |
| --- | --- |
| `GET` | `/`, `/cases` |
| `GET/POST` | `/cases/new`, `/cases` |
| `GET/PATCH` | `/cases/:slug`, `/cases/:slug/edit` |
| `GET` | `/cases/:slug/history` |
| `POST` | `/cases/:slug/history/:id/revert` |
| `POST` | `/cases/:slug/comments`, `/comments/:id/delete` |
| `POST` | `/cases/:slug/follows`, `/cases/:slug/unfollow` |
| `GET` | `/search?query=` |
| `GET/POST` | `/agencies`, `/agencies/new` |
| `GET/PATCH` | `/agencies/:slug`, `/agencies/:slug/edit` |
| `GET/POST` | `/organizations`, `/organizations/new` |
| `GET/PATCH` | `/organizations/:id`, `/organizations/:id/edit` |
| `GET` | `/articles`, `/articles/:slug` (301) |
| `GET` | `/about`, `/guidelines`, `/instructions`, `/get-involved`, `/how-to-help` |
| `GET/POST` | `/login`, `/logout`, `/register` |
| `GET` | `/users/confirmation?confirmation_token=` |
| `GET/POST` | `/password/new`, `/password`, `/password/edit`, `/password/update` |
| `GET/PATCH` | `/users/:id`, `/users/:id/edit` |
| `GET/POST` | `/admin/users` |

## One site locally

From the repo root, with Rails already able to boot and Hanami pointed at `blackops_development`:

```bash
chmod +x bin/one-site
bin/one-site
```

That binds **http://localhost:3000**. Public Hanami prefixes (all methods) go to
`:2300`; everything else goes to Rails `:3001`.

## Hanami only

```bash
cd apps/hanami
bin/setup
# apps/hanami/.env.local should match config/database.yml
# DATABASE_URL=postgres://blackops:PASSWORD@localhost:5432/blackops_development
bin/dev
```

http://localhost:2300

Do not run `LOAD_SCHEMA=1` against the Rails database. That flag is only for an empty throwaway DB.

## Railway staging

The Hanami sibling deploys as its own Railway service with root directory
`apps/hanami` (so Railway uses this Dockerfile, not the repo-root Rails image).
It uses a **separate** Railway Postgres — never the Heroku/Rails production
database.

**Staging service:** `hanami-web-production-dd15`  
**Public URL:** https://hanami-web-production-dd15.up.railway.app  
**Healthcheck:** `GET /up` (no basic auth; expect `200` and body `ok`)

### Required Railway variables

| Variable | Purpose |
| --- | --- |
| `DATABASE_URL` | Railway Postgres for this service only |
| `SESSION_SECRET` | Cookie signing (64+ chars) |
| `HANAMI_ENV` | `production` |
| `PORT` | Injected by Railway |
| `HTTP_BASIC_AUTH_USER` / `HTTP_BASIC_AUTH_PASSWORD` | Optional browser gate for staging |
| `STAGING_SEED_PASSWORD` | Demo account password when seeds run |
| `RESTORE_DUMP` | Set to `1` once on a throwaway DB to load historic data; unset after |
| `S3_BUCKET` / `S3_REGION` | Optional; without these, avatars use local `/uploads/...` paths |

Do not copy production Heroku `DATABASE_URL` into this service.

### Release and start

```bash
# After Railway injects PORT, DATABASE_URL, SESSION_SECRET, HANAMI_ENV=production
bin/railway-release   # optional dump restore, then schema if empty, then seed
bundle exec puma -C config/puma.rb
```

Railway should run `bin/railway-release` as the pre-deploy command and start
with `bundle exec puma -C config/puma.rb` (see `railway.toml`).

### Verify after deploy

1. `curl -sS https://hanami-web-production-dd15.up.railway.app/up` → `200 ok`
2. With basic auth (values from Railway variables, not committed):
   - `/` or `/cases` → case index with live count and pagination
   - `/cases/walter-scott` → overview, agencies (linked), cause of death, resources
   - `/search?query=Charleston` → Walter Scott in results
   - `/cases/does-not-exist` → `404`
3. Demo login (`admin@example.com` / password from `STAGING_SEED_PASSWORD`) → `/admin/users`

Rails production (`ebwiki.org`) is unchanged until an explicit cutover PR.

`latest.dump` is a Heroku custom-format snapshot from **2020-09-01**. It was
committed as `latest.dump` and later deleted from `main`; the blob is still at
commit `592560514b263c8956d039bdd25c9c8b7fb2a81f`. Set `RESTORE_DUMP=1` on a
**throwaway** database (Railway Postgres16) to download that file, `pg_restore`
it, rename `cases.cause_of_death_name` → `cause_of_death`, and add `cases.tsv`.
Unset `RESTORE_DUMP` after the first successful restore so later deploys do not
wipe writes.

```bash
# Local throwaway DB only — never the Rails/shared database
RESTORE_DUMP=1 DUMP_PATH=/tmp/latest.dump bin/restore-dump
```

Demo accounts (confirmed; password from `STAGING_SEED_PASSWORD`, default
`password123` only if that variable is unset):

- `admin@example.com` — staff
- `analyst@example.com` — analyst
- `editor@example.com` — signed-in editor

Seeds are skipped once `admin@example.com` exists. Do not point this release
command at a shared Rails database.

Set `HTTP_BASIC_AUTH_USER` and `HTTP_BASIC_AUTH_PASSWORD` to require a browser
login before the site. `/up` stays unauthenticated for Railway healthchecks.

## Tests

```bash
cd apps/hanami
HANAMI_ENV=test bundle exec rake db:load_schema
bundle exec rspec
```

## Style and security

Preferred Ruby style is **[Standard Ruby](https://github.com/standardrb/standard)** — the same `standard` gem already listed in the Rails Gemfile. Rails CI still uses the repo-root `.rubocop.yml` (Rails cops). New Hanami code follows Standard.

```bash
cd apps/hanami
bundle exec standardrb
bundle exec standardrb --fix
bundle exec rake lint
```

Hanami security scanning uses **[Dawnscanner](https://github.com/thesp0nge/dawnscanner)** plus bundler-audit. Dawnscanner reads this app’s `Gemfile.lock` and applies its knowledge base (CVE bulletins and generic Ruby checks). Rails CI still runs Brakeman on the Rails app.

```bash
bundle exec rake security:check
```

## Writes and identity on Hanami

- Login at `/login` checks `users.encrypted_password` with bcrypt (Devise-compatible). Unconfirmed accounts cannot sign in.
- `/register` writes an unconfirmed user and a `confirmation_token`. `/users/confirmation` matches Devise's token path. Mailers stay on Rails.
- Signed-in editors can create/edit cases, agencies, and organizations; comment; and follow.
- Case writes insert a `versions` row. Updates store a YAML `object` snapshot. Revert restores those columns. Create events with no snapshot are not undone and never delete the case.
- Staff at `/admin/users` can toggle `admin` / `analyst`.
- Case pages embed OpenStreetMap when `latitude` / `longitude` are present. CarrierWave keys are left unchanged.

Still on Rails: outgoing mail, writing new S3 objects, follower notification emails, a shared Devise session cookie, and deleting Rails itself.

Hanami reads existing CarrierWave keys (`uploads/case/avatar/:id/large_avatar_:filename`) and, when `S3_BUCKET` is set, prefixes the bucket host. It does not change object keys. The layout uses Bootstrap 3.4 CSS from the same major version as Rails.
