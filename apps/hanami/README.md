# EBWiki Hanami public site

Hanami 3 reads the existing Postgres schema. Rails still owns writes, identity, and PaperTrail inserts.

| Method | Path |
| --- | --- |
| `GET` | `/`, `/cases` |
| `GET` | `/cases/:slug` |
| `GET` | `/cases/:slug/history` (reads `versions`) |
| `GET` | `/search?query=` |
| `GET` | `/agencies`, `/agencies/:slug` |
| `GET` | `/articles`, `/articles/:slug` (301) |
| `GET` | `/about`, `/guidelines`, `/instructions`, `/get-involved`, `/how-to-help` |

## One site locally

From the repo root, with Rails already able to boot and Hanami pointed at `blackops_development`:

```bash
chmod +x bin/one-site
bin/one-site
```

That binds **http://localhost:3000** and splits traffic:

- GET of the public read paths above → Hanami (`:2300`)
- everything else (login, case editor, follow, admin) → Rails (`:3001`)

Or run the two apps on their own ports and compare slugs by hand.

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

## Tests

```bash
cd apps/hanami
HANAMI_ENV=test bundle exec rake db:load_schema
bundle exec rspec
```

## Still Rails

Auth, case/agency create and edit, follow emails, comment writes, maps, avatars beyond stored URLs, history revert, and staff tools.
