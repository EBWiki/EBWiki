# EBWiki Rails → Hanami: long-running branch until cutover

Read this first if you are catching up. Date: 2026-09-14.

`main` stays the live Rails app. Hanami accumulates on one long-running
branch and lands on `main` only when the sibling is feature-complete enough
to cut traffic. Railway staging is the place to click it before that.

## Process

1. **Long-running Hanami branch:** `cursor/hanami-first-slice-fe74`
   ([#4413](https://github.com/EBWiki/EBWiki/pull/4413), draft). All new
   Hanami work goes here. Rebase onto `main` when Rails moves; do not merge
   until cutover.
2. **Cutover PR** is that same PR (or a fast-forward of it) once the
   still-on-Rails list below is empty or explicitly deferred with a rollback
   plan. Cutover is: merge to `main`, point production at Hanami, then delete
   Rails in a follow-up.
3. **Rails-only cuts** (#4410 search, #4411 mailbox, #4412 staff tools) can
   still merge to `main` any time — they help today’s Rails app and shrink
   the dual-stack. They are not required to keep growing Hanami.
4. Do **not** merge [#4406](https://github.com/EBWiki/EBWiki/pull/4406)
   (Active Storage / Bootstrap 5 would drop CarrierWave keys Hanami reads).
5. [#4419](https://github.com/EBWiki/EBWiki/pull/4419) is superseded; maps
   and friendly photos live on #4413.
6. Never point Railway `DATABASE_URL` at Heroku production. Never run
   `LOAD_SCHEMA=1` or `RESTORE_DUMP=1` against the shared Rails database.
   Do not dual-send follower emails.

## Why not merge Hanami to `main` now

Merging `apps/hanami` early does not cut over `ebwiki.org`. It only puts an
unfinished second app on the default branch. A long-running branch keeps
`main` the production Rails tree, lets us rebase instead of emergency-revert,
and makes cutover one deliberate merge plus DNS/process change.

## What the long-running branch already has

Hanami 3 under `apps/hanami`, same Postgres schema as Rails.

| Area | Status |
| --- | --- |
| Case index / show / search | Done |
| Maps (`/maps`, Leaflet) | Done |
| Friendly photos (`/friendly_photos`) | Done (review only; no S3 write) |
| Case avatar writes | Done (CarrierWave keys; S3 when configured) |
| Agencies / organizations CRUD | Done |
| Auth (Devise bcrypt hashes) | Login + tokens + outgoing mail + **shared `_eb_wiki_session`** |
| Case/agency/org writes, comments, follows | Done |
| History + revert | Done (PaperTrail-compatible YAML) |
| Staff users + comment moderation + admin delete | Done |
| Railway staging | https://hanami-web-production-dd15.up.railway.app (`latest.dump`) |

**Local:** `cd apps/hanami && bin/dev` (port 2300) or repo-root `bin/one-site`.

Outgoing mail (confirmation, password reset, follower update, case deletion)
is sent by Hanami for Hanami writes. Rails still sends for Rails writes. SMTP
is off unless `HANAMI_SEND_MAIL=1` and `SMTP_*` (or SendGrid) are set — do
not enable that against the staging dump (real addresses). Do not dual-send
the same follower event.

Case photo uploads write the same CarrierWave keys Rails already reads
(`uploads/case/avatar/:id/` plus `large_avatar_`, `medium_avatar_`,
`small_avatar_`, `thumb_`). With `S3_BUCKET` and `AWS_ACCESS_KEY_ID` /
`AWS_SECRET_KEY_ID` they go to S3; otherwise they land under `public/`.
Do not change those keys. `/friendly_photos` still does not write S3.

Login writes the Rails `sessions` row and `_eb_wiki_session` cookie
(activerecord-session_store Marshal payload + Devise
`warden.user.user.key`). On the same host, Rails and Hanami share that
login. Different hosts (ebwiki.org vs Railway) cannot share the cookie —
expect a one-time re-login after cutover if people still have a Rails
cookie on the old host. `SECRET_KEY_BASE` is not required; the session id
is in the cookie and the payload is in Postgres.

Staging uses the PG dump already in git history: `latest.dump` at
`592560514b263c8956d039bdd25c9c8b7fb2a81f` (2020-09-01 Heroku snapshot).
Do not re-commit that blob. `bin/railway-release` restores it when
`RESTORE_DUMP=1` on the throwaway Railway Postgres — never against the
shared Rails/Heroku database. Unset `RESTORE_DUMP` after a successful
restore so later deploys keep writes.

## Feature-complete enough to cut over (still open)

These keep the work on the long-running branch:

- Production routing / DNS / process (Hanami `puma`, not `rails server`)
- Then: delete Rails

## Optional Rails PRs (independent of cutover)

| PR | What | Merge to `main`? |
| --- | --- | --- |
| [#4409](https://github.com/EBWiki/EBWiki/pull/4409) | Feasibility doc | Whenever; docs only |
| [#4410](https://github.com/EBWiki/EBWiki/pull/4410) | `pg_search`, drop Elasticsearch | Yes, anytime — Rails search is already on `tsv` |
| [#4411](https://github.com/EBWiki/EBWiki/pull/4411) | Drop Mailboxer | Yes if you accept dropping in-app inbox (`mailboxer_*` tables go) |
| [#4412](https://github.com/EBWiki/EBWiki/pull/4412) | Staff tools instead of Administrate | Yes if you want `/admin` smaller on Rails now |

## How to verify the long-running branch

```bash
cd apps/hanami
HANAMI_ENV=test bundle exec rake db:load_schema
bundle exec rspec
bundle exec standardrb
```

On Railway after an explicit redeploy of `hanami-web`:

1. `GET /up` → `200 ok`
2. `/`, `/cases/walter-scott`, `/search?query=Charleston`
3. `/maps`, `/friendly_photos`
4. Demo login `admin@example.com` (password from `STAGING_SEED_PASSWORD`)
5. Mail is covered by `bundle exec rspec spec/requests/mail_spec.rb`. Do not set
   `HANAMI_SEND_MAIL=1` on the restored dump.
6. Shared session is covered by `bundle exec rspec spec/requests/session_spec.rb`.
