# Lesson 01 — Why EBWiki moved to Hanami

**Runtime:** 12 minutes  
**Audience:** Rails maintainers who think a rewrite is either impossible or a weekend.

## The story

EBWiki documents people of color killed by law enforcement. The value is the
dataset: slugs, PaperTrail history, bcrypt passwords, CarrierWave object keys.
The pain was the gem pile: Devise, Searchkick, Mailboxer, Administrate,
CarrierWave, FriendlyId.

The 2026-08-19 study (`docs/HANAMI_MIGRATION.md` on #4409) said: do not start a
full rewrite yet. Do the Rails cuts first. Then Mark locked the north star on
2026-09-05: a **working Hanami version**, not a docs-only path.

That is the lesson. A feasibility study can say "don't." A product decision can
still say "do, but keep the database."

## What we kept

- Postgres schema (`db/structure.sql`)
- `/cases/:slug` URLs
- `users.encrypted_password` bcrypt hashes
- CarrierWave keys `uploads/case/avatar/:id/large_avatar_:filename`
- PaperTrail `versions` rows

## What we dropped on purpose

- Elasticsearch / Searchkick → `cases.tsv`
- Mailboxer in-app mail
- Administrate (14 dashboards) → `/admin/users`
- Running Rails and Hanami as two public apps

## Video beats

1. Open `ebwiki.org` (Rails / Heroku). That is still production.
2. Open `hanami-web-production-dd15.up.railway.app`. That is the new site.
3. Hold up `HANAMI_MIGRATION.md` vs this branch. Study vs slice.
4. Say the rule: never point Hanami `DATABASE_URL` at Heroku production.

## Exercise

List every gem in the Rails `Gemfile` that has no Hanami equivalent. For each,
write "reimplement," "delete," or "keep behind Rails for now."
