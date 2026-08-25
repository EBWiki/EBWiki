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

```bash
# After Railway injects PORT, DATABASE_URL, SESSION_SECRET, HANAMI_ENV=production
bin/railway-release   # load subset schema if empty, then seed demo rows
bundle exec puma -C config/puma.rb
```

Demo accounts (confirmed; password from `STAGING_SEED_PASSWORD`, default
`password123` only if that variable is unset):

- `admin@example.com` — staff
- `analyst@example.com` — analyst
- `editor@example.com` — signed-in editor

Seeds are skipped once `admin@example.com` exists. Do not point this release
command at a shared Rails database.

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
