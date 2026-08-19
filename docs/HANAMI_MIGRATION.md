# What it would take to migrate EBWiki to Hanami

_Snapshot as of 2026-08-19. Target: [Hanami 3.0](https://hanakai.org/blog/2026/06/30/hanami-3-0-in-full-bloom) (released 2026-06-30)._

This is a feasibility study, not a commitment to migrate. It is grounded in the current Rails 8.1 codebase, not a generic Rails-vs-Hanami comparison.

## Bottom line

Migrating EBWiki to Hanami would be a **full rewrite of the application layer**, not a framework upgrade. The Postgres database, S3 uploads, and public URLs can be preserved. Almost nothing else can.

EBWiki is a volunteer-maintained wiki whose value lives in features that are tightly coupled to Rails-only gems: Devise, PaperTrail, Administrate, CarrierWave, FriendlyId, Mailboxer, Simple Form, Cocoon, CKEditor, and Searchkick. Hanami 3.0 is a mature, modular Ruby web framework, but it does not provide drop-in replacements for those gems. Each one has to be reimplemented or swapped.

The current project phase is Rails 8.1 modernization (Administrate, Devise 5, Sprockets 4, security). A Hanami rewrite would freeze or discard that work and raise the bar for new contributors, most of whom arrive expecting Rails.

**Recommendation:** do not start a full rewrite. If the goal is Hanami-style architecture (explicit actions, repositories, operations), extract further in Rails first — the app already has `app/queries`, `app/services`, `app/presenters`, and `app/policies`. If someone still wants proof that Hanami can host this domain, do a **timeboxed spike** of public case index/show against a read-only replica of production data, then stop and reassess.

---

## What EBWiki is today

| Layer | Current state |
| --- | --- |
| Language / app | Ruby 3.4.2, Rails 8.1.3 |
| Persistence | Postgres (`schema_format = :sql`), ActiveRecord, 29 tables |
| Search | `pg_search` on cases (`tsv` column) plus leftover Searchkick/Elasticsearch wiring |
| Auth | Devise (`database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `trackable`, `confirmable`) + Pundit |
| History | PaperTrail on `Case` and `Agency`, with revert |
| Admin | Administrate (`/admin/*`, 14 resources) |
| Uploads | CarrierWave + MiniMagick + fog-aws → S3 |
| Slugs | FriendlyId (`/cases/:slug`, `/agencies/:slug`, users) |
| Messaging | Mailboxer (inbox / sent / trash / conversations) |
| Follows | `acts_as_follower` (EBWiki fork) |
| Front end | Sprockets 4, jQuery, Bootstrap 3, Simple Form, Cocoon nested forms, CKEditor 4 CDN |
| Maps | HERE Maps JS SDK + Redis-cached lat/lng JSON |
| Hosting | Heroku (staging + production), Puma, Redis, Elasticsearch 6.8 in CI |
| Tests | 64 RSpec files (~2,500 lines), Capybara features, FactoryBot, VCR |
| Size | ~20 models (~770 LOC), ~1,500 LOC of ERB, ~1,500 LOC of controllers, ~1,200 LOC of Administrate dashboards |

Public surface that must keep working after any rewrite:

- `GET /` case index with pagination
- `GET /cases/:slug` (and `/articles/:slug` redirects)
- Case create/edit with nested subjects, links, agencies, avatar, CKEditor fields
- Case history + revert
- Follow / unfollow + follower notification emails
- Agency CRUD, organizations, maps, search
- User registration (reCAPTCHA), sessions, profiles
- Mailbox
- `/admin` for admins
- Existing slugs, password hashes, S3 object keys, PaperTrail `versions` rows

---

## What Hanami 3.0 actually provides

Hanami is a **modular** framework. You assemble an app from first-party gems rather than inheriting a monolith. As of 3.0:

| Hanami piece | Rails analogue | Notes |
| --- | --- | --- |
| `Hanami::Action` + router (`resources`) | Controllers + `routes.rb` | Resource routes returned in 2.3; 3.0 adds explicit 301/302 helpers. Good fit for EBWiki's REST-ish surface. |
| `Hanami::View` (exposures, parts, layouts) | Action View | ERB templates can be reused *as markup*, but helpers, `form_for`, Simple Form, and `link_to` do not exist. Views are standalone objects (useful for mail). |
| ROM + Sequel (`Hanami::DB`) | ActiveRecord | Relations, repositories, structs. No callbacks, no `accepts_nested_attributes_for`, no `has_paper_trail`, no `enum` macros. |
| `dry-validation` contracts | Strong params + model validations | Validations live at the boundary, not on the record. |
| Hanami Mailer (new in 3.0) | Action Mailer | First-class, injectable. SMTP via env vars. Fine for CaseMailer / UserMailer / AdminMailer. |
| i18n (new in 3.0) | Rails I18n | Enough for current `en.yml` / Devise copy if we rewrite keys. |
| esbuild assets | Sprockets | jQuery + Bootstrap 3 + Cocoon + moment + select2 need to be imported as npm packages or vendored. |
| Slices | Engines / namespaces | Natural split: `main` (public wiki), `admin`, `identity`. |
| RSpec (default) or Minitest | rspec-rails | Request specs can be ported; view specs and `shoulda-matchers` cannot. |
| Puma | Puma | Same process model; Heroku `Procfile` stays similar. |

Hanami does **not** ship: ActiveRecord, Devise, PaperTrail, Administrate, CarrierWave, FriendlyId, Action Cable, Active Job, Active Storage, or a CMS/admin generator.

There is still **no first-party job backend**. Follower emails currently use `deliver_now`. A rewrite should introduce a real queue (Sidekiq + Redis, which we already run) rather than sending mail in the request.

Auth in the Hanami ecosystem is **Rodauth** (Roda middleware in a slice), not Devise. See [Tim Riley, "Rodauth, meet Hanami"](https://timriley.info/posts/rodauth-meet-hanami) and [janko/hanami-rodauth-example](https://github.com/janko/hanami-rodauth-example/).

---

## The hard parts (ranked)

These are ordered by how much they would dominate the rewrite. The first four are likely deal-breakers unless someone is prepared to own them for the life of the project.

### 1. Persistence rewrite: ActiveRecord → ROM

This is the largest technical change. `Case` today is a typical fat model:

- `enum :cause_of_death`
- polymorphic `has_many :links, :comments, :follows`
- `accepts_nested_attributes_for :links, :subjects, :case_agencies`
- `has_paper_trail`
- `acts_as_followable`
- `friendly_id`
- `mount_uploader :avatar`
- `geocoded_by` + `before_save :geocode`
- `pg_search_scope`
- custom validators and `sanitize` callbacks

In Hanami that becomes:

- a `cases` relation (SQL / associations)
- a `CaseRepository` (find by slug, nested write, nearby cases)
- a `Case` struct (or entity) with domain methods like `full_address`
- an operation (`CreateCase` / `UpdateCase`) that validates with a contract, geocodes, writes children, records a version, updates the search vector, and follows the author

Nested writes (subjects + links + agencies in one form post) have to be explicit Sequel transactions. There is no `accepts_nested_attributes_for`. Cocoon's `link_to_add_association` has to be replaced with Stimulus/vanilla JS that clones fieldsets.

Polymorphic associations (`links.linkable`, `comments.commentable`, `follows.followable`) work in ROM but you write the combine/load logic yourself. The recent polymorphic `linkable` work on CalendarEvent must be preserved.

**Keep the database.** Do not generate a new schema. Point Hanami migrations at the existing Postgres, import `db/structure.sql` as the baseline, and only add ROM migrations going forward. `schema_migrations` versioning differs between ActiveRecord and Sequel — plan a one-time cutover so Heroku does not try to re-run 56 Rails migrations.

### 2. Authentication: Devise → Rodauth

`users` already has Devise's confirmable / recoverable / trackable columns and bcrypt `encrypted_password`. Rodauth can authenticate against that table if we configure:

- bcrypt (same cost/format Devise uses)
- `password_hash` column mapping (`encrypted_password`)
- account verification from `confirmation_token` / `confirmed_at`
- reset from `reset_password_token` / `reset_password_sent_at`

Trackable (`sign_in_count`, IPs) and FriendlyId slugs on users are custom. `Guest` is a PORO and ports easily. reCAPTCHA on registration is a before-create hook in `Users::RegistrationsController` — reimplement in the Rodauth create-account hook.

Sessions today use `activerecord-session_store` (`sessions` table). Hanami typically uses Rack cookie sessions or Redis. Either keep the `sessions` table via a Rack store or accept logging everyone out once.

Pundit policies (`CasePolicy#destroy?` is admin-only; similar for agencies/orgs/users) port cleanly: they are plain Ruby. Call them from actions.

### 3. Editorial history: PaperTrail

Case history and revert are core product, not admin niceties. `versions` and `version_associations` must keep working for existing rows.

PaperTrail is ActiveRecord-only. Options:

1. **Write a Sequel-backed audit log** that reads the existing YAML/JSON `object` column and implements `reify` + revert. This is the only option that preserves history.
2. Freeze old versions as read-only and start a new audit table for Hanami writes. Worse UX; still need a reader for old rows.
3. Keep a tiny Rails process around only for history. That is not a migration.

`Cases::VersionsController#revert` is already fragile. A rewrite should replace it with an explicit `RevertCase` operation and tests against production-like `versions` fixtures.

YAML serialization of PaperTrail objects (`config/initializers/paper_trail_yaml.rb`) is a security/compat concern either way.

### 4. Admin: Administrate → a new admin slice

~1,200 lines of dashboards plus 14 generated-style controllers. There is no Hanami Administrate. Realistic options:

- A Hanami `admin` slice with list/show/edit actions per resource (most work, best fit).
- [Rodauth](https://rodauth.jeremyevans.net/) is not an admin.
- Mount a separate tool (Hope, a small CRUD layer, or even keep Rails Administrate behind a path during strangler).

Admin is used by a small set of people. It is a good **last** slice to migrate, not the first.

### 5. Uploads: CarrierWave → Shrine or a thin S3 wrapper

Avatars live under `uploads/#{model}/#{mounted_as}/#{id}` with versions `large_avatar`, `medium_avatar`, `small_avatar`, `thumb`. **Object keys on S3 must not change**, or every case image 404s.

[Shrine](https://shrinerb.com/) works with Sequel/ROM and can be pointed at the existing fog-aws credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_KEY_ID`, `S3_BUCKET`). Reimplement MiniMagick versions and `default-user-icon.png` fallback. `carrierwave-imageoptimizer` needs an equivalent `image_optim` step.

CKEditor file uploads (`mount Ckeditor::Engine`) are a separate uploader path; confirm whether production still uses it or only the CDN editor for text.

### 6. Search: finish the Elasticsearch exit, then wrap Postgres

The live case model uses `pg_search` (`CaseSearchable` / `tsv`). `CaseSearch` still calls `Case.search` (Searchkick API), Searchkick is still in the Gemfile, CI still boots Elasticsearch 6.8, and `docs/DEPLOYING.md` still says `searchkick:reindex:all`. That split has to be cleaned up in Rails *or* in Hanami; it is cheaper to clean up in Rails first.

A Hanami `CaseRepository#search` can call the same `tsv` column via Sequel `plainto_tsquery`. Kaminari pagination becomes a repository `limit`/`offset` (or `rom-sql` pager). Drop Elasticsearch from CI/Heroku if pg_search is enough.

### 7. Front end: Sprockets + jQuery + Bootstrap 3

~1,100 lines of JS/SCSS plus gem-provided assets (`bootstrap-sass`, `jquery-rails`, `select2-rails`, `momentjs-rails`, `cocoon`, `social-share-button`, `ckeditor`). Hanami assets are esbuild.

This is a chance to leave Bootstrap 3, but that is a visual redesign, not a framework port. A conservative migration vendors the current CSS/JS as static entrypoints so the site looks the same, then modernizes later.

Simple Form + Cocoon nested forms are the painful bit: Hanami has no form builder of that depth. Plan on hand-written forms or a small helper object, plus JS for "Add a Subject" / "Add a Link".

CKEditor 4 is loaded from CDN (`//cdn.ckeditor.com/4.6.1/standard/ckeditor.js`). It can stay as a script tag; it does not need Rails.

### 8. Follows and mailbox

`acts_as_follower` is an EBWiki-maintained fork. The `follows` table is ordinary polymorphic data — a repository plus `Follow`/`Unfollow` operations replace the gem.

Mailboxer is not. It owns four tables (`mailboxer_conversations`, `notifications`, `receipts`, `conversation_opt_outs`) and mailer templates. Reimplementing a small inbox against those tables is feasible; keeping the gem is not (it is ActiveRecord). If mailbox usage is low, consider dropping in-app messaging and using email only — that is a product decision, not a technical one.

### 9. Everything else that looks small until it is not

| Feature | Rails today | Hanami approach |
| --- | --- | --- |
| Slugs | FriendlyId + `friendly_id_slugs` | Repository lookup by `slug`; keep unique indexes; port `slug_candidates` |
| Geocoding | `geocoder` callbacks | Call Geocoder from the operation before insert (the gem is not AR-specific) |
| Maps | `Rails.cache` 12h TTL + HERE JS | Redis cache component + same `maps.js` |
| Mailchimp | Gibbon in `User#mailchimp_status` | Move to an operation; do not call Mailchimp from a struct |
| Feature flags | Rollout (initializer currently commented out) | Same Redis-backed gem, or drop |
| Sitemap | `sitemap_generator` + Whenever | Rake task writing to S3; keep |
| Analytics | leftover `ahoy_events` / `visits` tables | Leave tables; do not port unused code |
| Recurring events | Montrose `serialize` on `calendar_events.schedule` | Keep JSONB; Montrose is PORO-friendly |
| Observability | Rollbar, New Relic, Lograge, Cloudflare gem | Rack middleware ports; Lograge is Rails-oriented — use Hanami 3 structured logging |
| Hosting | Heroku `rails server`, `rake db:migrate` | `hanami server`, Sequel migrations, Node for esbuild on slug compile |
| Docker / CI | Rails-centric Dockerfile and workflow | New image, no Elasticsearch if search is Postgres-only, Brakeman does not understand Hanami well |

---

## Approaches (if we did it anyway)

### A. Strangler fig (only viable production path)

Run Rails and Hanami on the same Postgres. Route a subset of traffic to Hanami.

1. Stand up a Hanami 3 app in-repo (`apps/hanami` or a sibling service) sharing `DATABASE_URL`.
2. Port **read-only** `cases#index` and `cases#show` (plus `/articles` redirects). These are the public wiki.
3. Put a reverse proxy (Heroku vs two dynos, or Rack `URLMap`) in front: Hanami for `/` and `/cases/:slug`, Rails for everything else.
4. Move writes (create/edit, follows, comments) once repositories and contracts are proven.
5. Move identity (Rodauth) only after password verification is tested against production hashes in staging.
6. Move admin last, or never — leaving Administrate on Rails behind `/admin` is acceptable.

**Do not** dual-write PaperTrail from both apps without a single writer.

### B. Big-bang rewrite in a new repo

Freeze Rails, rebuild, cut over on a weekend. This maximizes calendar risk and contributor dropout. Not recommended for a living dataset of police-violence cases.

### C. "Hanami-shaped Rails" (recommended default)

Stay on Rails 8.1. Continue extracting:

- operations for case create/update/revert (already implied by fat `CasesController`)
- repositories/query objects (already have `CaseQuery`, `FollowQuery`, `CaseSearch`)
- drop Searchkick once `search_text` is wired through `CaseSearch`
- replace CKEditor 4 when convenient
- treat Administrate as the admin, not as domain logic

This captures most of the architectural benefit without abandoning the contributor pool or the gem ecosystem that is carrying history, auth, and admin.

---

## Suggested spike (timeboxed, throwaway)

If maintainers want an empirical answer instead of this document:

**In scope**

- `hanami new ebwiki --name=EBWiki` on Ruby 3.4
- ROM relations for `cases`, `states`, `subjects` against a restored production dump (read-only)
- `GET /` and `GET /cases/:slug` with the existing ERB show template copied and stripped of Rails helpers
- Prove FriendlyId slugs resolve
- Prove `tsv` search via Sequel
- Docker Compose with Postgres only

**Out of scope**

- Auth, admin, uploads, writes, mailbox, assets pipeline, Heroku

**Exit criteria**

- A staging URL that renders a real case page from production data
- A written list of helpers/partials that blocked rendering
- A go / no-go from maintainers

If the spike cannot render `cases/show` without inventing a form builder and an uploader, the rewrite is not cheaper than it looks on paper.

---

## Contributor and product cost

EBWiki's contributing docs, Codespaces/Docker setup, and "good first issue" pipeline all assume Rails. A Hanami app would need:

- New setup docs (`hanami db prepare`, `npm` for assets)
- Reviewers fluent in ROM and dry-rb
- A freeze on Rails feature work during overlap
- Acceptance that many current gems (shoulda-matchers, factory_bot_rails, annotate, bullet, brakeman-on-Rails) stop applying

The mission — documenting people of color killed by law enforcement — does not get better from a framework change. Downtime, broken slugs, lost images, or a stalled contributor pipeline would make it worse.

---

## Open questions to answer before any real work

1. Is Elasticsearch still required in production, or is `pg_search` the source of truth?
2. How much is mailbox actually used? Can it be dropped?
3. Must `/admin` stay Administrate-shaped, or is a simpler CRUD acceptable?
4. Are we willing to log everyone out once (session store change)?
5. Who owns PaperTrail-on-Sequel if we start?
6. Is Bootstrap 3 considered frozen visual identity for the rewrite?

---

## References in this repo

- Domain model: `app/models/case.rb`, `app/models/user.rb`, `app/models/agency.rb`
- Nested case writes: `app/controllers/cases_controller.rb`, `app/views/cases/_form.html.erb`
- History: `app/controllers/cases/versions_controller.rb`
- Search split: `app/models/concerns/case_searchable.rb` vs `app/search/case_search.rb`
- Maps: `docs/MAPPING_CASES.md`
- Deploy: `docs/DEPLOYING.md`
- Current phase: `docs/PROJECT_STATE.md` (Rails 8.1 modernization)

External:

- [Hanami 3.0 announcement](https://hanakai.org/blog/2026/06/30/hanami-3-0-in-full-bloom)
- [Hanami 2.3 (resource routes, Rack 3)](https://hanakai.org/blog/2025/11/12/hanami-23-racked-and-ready)
- [Hanami persistence (ROM)](https://hanakai.org/learn/hanami/v2.3/database)
- [Rodauth + Hanami](https://timriley.info/posts/rodauth-meet-hanami)
- [Hanami for Rails developers (models)](https://ryanbigg.com/2025/10/hanami-for-rails-developers-1-models)
