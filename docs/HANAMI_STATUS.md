# EBWiki Rails → Hanami: what landed and what is left

Read this first if you are catching up. Date: 2026-09-14.

Mark authorized merge of the independent Hanami-track PRs as long as the
changes are written down. This file is that write-down. Rails is **not**
deleted. Production `ebwiki.org` is **not** cut over.

## Process (now)

1. Each slice is its own PR so it can be merged, skipped, or replaced.
2. CI must be green on the PR head.
3. Draft → ready for review → merge (squash unless GitHub requires otherwise).
4. Merge order: docs → Rails cuts → Hanami sibling. Do not merge #4406 as-is
   (Active Storage / Bootstrap 5 / mailbox rewrite would drop CarrierWave keys
   Hanami still reads).
5. #4419 is superseded by #4413 (maps and friendly photos now live there).
6. After merge: rebase any leftover Hanami branches; redeploy Railway only on
   throwaway Postgres; never point `DATABASE_URL` at Heroku production.

## PRs

| PR | What it is | Why merge it |
| --- | --- | --- |
| [#4409](https://github.com/EBWiki/EBWiki/pull/4409) | `docs/HANAMI_MIGRATION.md` feasibility study | Written SoT for constraints |
| [#4410](https://github.com/EBWiki/EBWiki/pull/4410) | Rails `CaseSearch` → `pg_search`; drop Elasticsearch | Search works on Rails or Hanami |
| [#4411](https://github.com/EBWiki/EBWiki/pull/4411) | Remove Mailboxer / in-app messaging | Drops a Rails-only gem; keeps follower emails |
| [#4412](https://github.com/EBWiki/EBWiki/pull/4412) | Replace Administrate with staff tools | Matches Hanami’s small `/admin` |
| [#4413](https://github.com/EBWiki/EBWiki/pull/4413) | Hanami sibling app in `apps/hanami` | Working public site + writes |

## What #4413 actually ships

Hanami 3 app under `apps/hanami`, same Postgres schema as Rails.

**Reads:** `/`, `/cases`, `/cases/:slug`, `/search`, `/maps`, `/agencies`,
`/organizations`, static pages, `/articles` → `/cases` 301.

**Writes (signed-in):** case / agency / org create+edit, comments, follows,
PaperTrail-compatible history + revert, admin deletes.

**Identity:** bcrypt against `users.encrypted_password` (Devise-compatible).
Confirmation and reset **tokens** are written; **emails are not sent**.

**Photos:** `/friendly_photos` searches Commons / Wikipedia / Openverse and
flags likely mugshots. Existing CarrierWave S3 **keys are read, not rewritten**.

**Staging:** https://hanami-web-production-dd15.up.railway.app (basic auth).
Data there is a **2020** Heroku dump, not current production.

**Local:** `cd apps/hanami && bin/dev` (port 2300) or repo-root `bin/one-site`.

## Still on Rails (later slices)

- Outgoing mail: confirmation, password reset, follower notifications
- Writing new S3 objects
- Shared session cookie with Rails (Hanami uses `ebwiki.session`)
- Production DNS / Heroku cutover
- Deleting the Rails app
- A current production dump (staging is 2020)

Do **not** dual-send follower emails from both apps. Do **not** run
`LOAD_SCHEMA=1` or `RESTORE_DUMP=1` against the shared Rails database.

## How to verify after merge

```bash
cd apps/hanami
HANAMI_ENV=test bundle exec rake db:load_schema
bundle exec rspec
bundle exec standardrb
```

On Railway (after an explicit redeploy of `hanami-web`):

1. `GET /up` → `200 ok`
2. `/` live case count, `/cases/walter-scott`, `/search?query=Charleston`
3. `/maps`, `/friendly_photos`
4. Demo login `admin@example.com` (password from `STAGING_SEED_PASSWORD`)
