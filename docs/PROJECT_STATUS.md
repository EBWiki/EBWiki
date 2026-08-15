# EBWiki Project Status

## Current stack

- Ruby 3.4.2
- Rails 8.1.3.1
- Postgres 17 (full-text search via `pg_search` / `cases.tsv`)
- Redis
- Active Storage for case photos
- Propshaft, importmap, Turbo, Stimulus, dartsass, Bootstrap 5

## Known leftovers that were removed

Mailboxer tables, CarrierWave columns, cucumber rake/config, CKEditor, Searchkick/Elasticsearch, Sprockets/jQuery, and Bootstrap 3 markup are gone from this branch.

## Pending product follow-ups

- Restore branded favicon PNGs if the original icon set is recovered (the layout currently uses the safari SVG only)
- Optional later gem majors (`bundle outdated`) that were intentionally not taken

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) - Development setup and workflow
- [SETUP_LOCALLY.md](SETUP_LOCALLY.md) - Docker setup
- [SETUP_LOCALLY_FULLSTACK.md](SETUP_LOCALLY_FULLSTACK.md) - Full local setup
- [E2E.md](E2E.md) - Playwright e2e in CI / Cloud Agent (not on a local laptop)
