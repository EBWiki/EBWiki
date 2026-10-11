# EBWiki Rails staging on Railway

This document describes how the **Rails** EBWiki archive deploys to Railway from
`main`, how it differs from [hanami.ebwiki.org](http://hanami.ebwiki.org), and
which environment variable **names** belong in Doppler config `ebwiki/stg`
(values live only in Doppler and Railway — never commit them).

Linear: [GKT-460](https://linear.app/gkt/issue/GKT-460).

## Deploy path

1. Merge-ready changes land on GitHub `main`.
2. Railway watches `main` on `EBWiki/EBWiki` and builds with
   **`Dockerfile.railway`** (see `railway.toml`).
3. **Pre-deploy:** `bash release-tasks.sh`, which runs **`rails db:migrate` only**
   (same as the ebwiki-web review service). This does **not** load
   `db/seeds.rb` (seeds are limited to development and test) and does **not**
   create tables on an empty database.
4. **Start:** `bundle exec puma -C config/puma.rb`.
5. **Liveness (Railway deploy health check):** HTTP `GET /up` — fast “app booted”
   probe only (`railway.toml` `healthcheckPath`). Returns **200** when Rails is
   up; **503** if the liveness handler errors. JSON may include `deploy_rev`.
6. **Readiness (operators):** HTTP `GET /health` — checks Postgres (`SELECT 1`),
   Redis (`PING` via `REDIS_URL`), and Elasticsearch (cluster ping via
   `ELASTICSEARCH_URL` or legacy `SEARCHBOX_URL`). Each check uses a ~2s timeout.
   JSON shape: `{ "status", "checks": { "postgres"|"redis"|"elasticsearch":
   { "status", "latency_ms" } }, "deploy_rev" }`. Returns **200** when all pass,
   **503** when any fail. Responses never include error messages or secrets.
7. **Revision in HTML:** Every page includes `<!-- deploy_rev: … -->` in the
   footer when `DEPLOY_REV` or `RAILWAY_GIT_COMMIT_SHA` is set (same SHA as
   `/up` and `/health`).

The root **`Dockerfile`** is unchanged for the Docker Hub workflow
(`.github/workflows/publish_docker_image.yml`). Only Railway uses
`Dockerfile.railway`.

Database config is **not** committed: the image copies
`config/database.railway.yml` to `config/database.yml` at build time so staging
boots from **`DATABASE_URL`** only. The image installs **PostgreSQL client 17**
(PGDG) so `pg_dump` matches Postgres 17 features in `db/structure.sql` (for
example `SET transaction_timeout`).

## How this host differs from hanami.ebwiki.org

| | **Rails staging (this doc)** | **hanami.ebwiki.org** |
| --- | --- | --- |
| App | Full Rails 8.1 archive on `main` | Hanami 3 sibling app (`apps/hanami`) |
| Railway project | EBWiki staging Rails service (target: staging.ebwiki.org) | `ebwiki-hanami-staging` |
| Build file | `Dockerfile.railway` at repo root | `apps/hanami/Dockerfile` |
| Role | Full Rails archive: cases, search, mailers, admin, etc. | Public read-focused slice; Rails still owns many write paths |

Both can share Postgres patterns via `DATABASE_URL`, but they are **separate**
Railway services and codebases.

## Database on a new Postgres instance

Each deploy runs **`db:migrate`** against the service’s `DATABASE_URL`. If the
database is **empty** (no tables yet), migrate has nothing to apply and the app
will not boot until a schema exists.

**One-time setup** (pick one, as an operator with access to the Railway service
shell or a local `DATABASE_URL` pointing at that database):

- Load the committed schema: `bundle exec rails db:schema:load`
- Or restore from a Postgres dump taken from another EBWiki environment

After that, normal deploys only need `db:migrate`. Do not run `db:seed` or
`db:setup` on staging: `db/seeds.rb` uses FactoryBot and demo users and is
restricted to development and test.

## Rollback

**Redeploy an older build in Railway:** open the service → **Deployments** →
select a previous successful deployment → **Redeploy**. That rolls the **running
code and container image** back; it does **not** reverse migrations.

**Migrations are forward-only.** Rolling code back leaves the database at the
newer schema version. Options:

- **Fix forward:** ship a new commit on `main` that corrects the problem and
  migrate again.
- **Manual down (rare):** run `rails db:migrate:down` (or a targeted rollback)
  from a one-off shell against staging only when you know the exact migration to
  reverse and accept the data risk.

**Confirm what is live:** `GET /up` and `GET /health` with `Accept:
application/json`. Check `deploy_rev` (from `DEPLOY_REV` or
`RAILWAY_GIT_COMMIT_SHA`) matches the deployment you expect. View page source
for `<!-- deploy_rev: … -->` in the footer when browsing the site.

## Doppler mapping (`ebwiki/stg`)

Set each name below in Railway (or sync from Doppler `ebwiki/stg`). Names match
1:1 unless noted. For local development, the same names (with comments on
required vs optional) are grouped in `.env.example`.

### Core runtime

| Variable | Purpose |
| --- | --- |
| `RAILS_ENV` | Must be `staging` for this service |
| `RACK_ENV` | Same as `RAILS_ENV` |
| `SECRET_KEY_BASE` | Rails signed cookies / secrets |
| `DATABASE_URL` | Postgres (sole DB config at runtime) |
| `REDIS_URL` | Cache / Action Cable (see `config/environments/staging.rb`) |
| `PORT` | Injected by Railway; Puma binds via `config/puma.rb` |
| `HOST` | Custom public hostname allowed in staging host authorization (with Railway’s domain; see below) |

### Deploy visibility

| Variable | Purpose |
| --- | --- |
| `DEPLOY_REV` | Optional explicit git SHA for `/up` and footer |
| `RAILWAY_GIT_COMMIT_SHA` | Auto-set by Railway when deploying from GitHub |

### AWS / uploads

| Variable | Purpose |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | S3 / CarrierWave (optional on staging: file storage when unset) |
| `AWS_SECRET_KEY_ID` | S3 secret (note `_KEY_ID` suffix in this app) |
| `S3_BUCKET` | Upload bucket |
| `FOG_DIRECTORY` | Sitemap / Fog directory name |

### Search

| Variable | Purpose |
| --- | --- |
| `ELASTICSEARCH_URL` | Preferred Elasticsearch URL |
| `SEARCHBOX_URL` | Legacy fallback (`config/initializers/searchbox.rb`) |

### Mail / marketing

| Variable | Purpose |
| --- | --- |
| `MAILCHIMP_API_KEY` | Mailchimp API |
| `MAILCHIMP_LIST_ID` | List for subscriptions |
| `MAILCHIMP_LINK` | Newsletter signup link in header |

### Analytics / maps

| Variable | Purpose |
| --- | --- |
| `GOOGLE_ANALYTICS_MEASUREMENT_ID` | gtag.js in layout |
| `GOOGLE_TAG_MANAGER_ID` | GTM noscript iframe |
| `GOOGLE_MAPS_API_KEY` | Geocoder |

### Observability / misc

| Variable | Purpose |
| --- | --- |
| `ROLLBAR_ACCESS_TOKEN` | Error reporting |
| `ROLLBAR_ENV` | Rollbar environment label |
| `EBWIKI_SITEMAP_URL` | Sitemap URL reference |
| `RECAPTCHA_SITE_KEY` | reCAPTCHA site key (if enabled) |
| `RECAPTCHA_SECRET_KEY` | reCAPTCHA secret |

### Railway-injected (read-only)

Railway adds names such as `RAILWAY_ENVIRONMENT`, `RAILWAY_PUBLIC_DOMAIN`,
`RAILWAY_SERVICE_*`, and related `RAILWAY_*` variables. Do not duplicate them in
Doppler unless you intentionally override; they are not part of `ebwiki/stg`.

**Host authorization on staging** (`config/initializers/staging_railway_hosts.rb`)
allows only `HOST` (when set) and `RAILWAY_PUBLIC_DOMAIN` (Railway’s default
service URL host). It does not allow every `*.railway.app` subdomain. Railway’s
deploy health check hits `GET /up`, which is excluded from host authorization so
liveness probes succeed before a custom domain is attached.

## Operator checklist

- [ ] Railway service: repo `EBWiki/EBWiki`, branch `main`, Dockerfile path
  `Dockerfile.railway`.
- [ ] Variables synced from Doppler `ebwiki/stg` (names above).
- [ ] Health check path `/up` returns **200**.
- [ ] After deploy, `curl -sS -H 'Accept: application/json' https://<host>/up`
  shows `deploy_rev` matching the deployed `main` commit.
