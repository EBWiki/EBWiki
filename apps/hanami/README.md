# EBWiki Hanami first slice

This is increment 1 of a strangler-fig migration: a Hanami 3.0 app that **reads** the existing Postgres schema and serves the public wiki pages.

| Method | Path | Rails equivalent |
| --- | --- | --- |
| `GET` | `/` | `cases#index` |
| `GET` | `/cases` | `cases#index` |
| `GET` | `/cases/:slug` | `cases#show` via FriendlyId |
| `GET` | `/articles` | 301 → `/cases` |
| `GET` | `/articles/:slug` | 301 → `/cases/:slug` |

Writes, auth, history, uploads, search, follows, comments, and staff tools stay on Rails.

## Why a sibling app

The analysis in the earlier study still holds: persistence, Rodauth, and PaperTrail-compatible history are the expensive parts. This slice answers a narrower question: can Hanami render a real case page from the production-shaped `cases` / `subjects` / `states` / `agencies` / `links` tables without changing those tables?

Schema ownership stays with Rails (`db/structure.sql`). There are no Hanami migrations.

## Run it

Ruby 3.4.2. From this directory:

```bash
bin/setup
# Point .env DATABASE_URL at the Rails development database, then:
bin/dev
```

The app listens on [http://localhost:2300](http://localhost:2300).

To use an empty database instead of the Rails one:

```bash
createdb ebwiki_hanami
DATABASE_URL=postgres://localhost/ebwiki_hanami bundle exec rake db:load_schema
```

That loads `config/db/existing_schema.sql`, a subset of the Rails tables this slice reads.

## Tests

```bash
HANAMI_ENV=test bundle exec rake db:load_schema
bundle exec rspec
```

CI creates `ebwiki_hanami_test` and runs the same commands. See `.github/workflows/hanami.yml` at the repo root.

## What this does not do

- No Devise / Rodauth
- No PaperTrail history or revert
- No CarrierWave version reconstruction beyond `default_avatar_url` / stored filename
- No case editor, follows, comments, or maps
- Visual identity is a readable stand-in, not a Bootstrap 3 port

Next increments (separate PRs): search via `cases.tsv`, then writes, then identity.
