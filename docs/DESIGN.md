# EBWiki design bar

This is the documented bar for remaining UI and architecture work. It is not
a redesign. New screens and refactors must fit this, or change this file in
the same PR.

## Product

EBWiki documents cases of people of color killed by law enforcement. The
interface is a public archive first: readable case pages, search, agencies,
and contributor forms. Decorative redesign (Harbor, new CSS frameworks,
Hanami cutover) stays on draft spikes until the review path in
`docs/BOT_REVIEW_CLEANUP.md` is the one in use.

## Visual system (current, required)

- **Framework:** Bootstrap 3 via `bootstrap-sprockets` in
  `app/assets/stylesheets/application.scss`. Simple Form uses the Bootstrap
  wrappers in `config/initializers/simple_form_bootstrap.rb`.
- **Layout:** `app/views/layouts/application.html.erb` — `container`,
  header, `col-md-8` main column, footer. New pages use this layout unless
  they are a documented embed (`embed.scss`).
- **Color:** `$color-orange: #F65732` is the brand accent
  (`application.scss`, `bootstrap-mods.scss`). Do not introduce a second
  primary orange.
- **Type:** `verdana, arial, helvetica, sans-serif` on `html`.
- **Assets:** Sprockets. Per-feature sheets (`cases`, `search`, `forms`,
  …). Add a new sheet only for a new feature; do not dump one-off rules
  into `scaffolds.scss`.

Do not add Tailwind, Bootstrap 5, or a second component library on a
feature PR. That is a migration, same class as Puma 7 → 8.

## What a required check is

A **required check** has two outcomes: **pass** or **not done**. That
is stricter than a guideline or a preference, and it is not the same
as the name of a CI job. The change is incomplete until every
applicable check has been run and has passed. “Could not run it” is
**not done**.

Two kinds apply here:

- **Quality checks** (next section) — product checks you run: browser,
  shared state, empty/error, viewport, focus, copy.
- **Merge requirements** — GitHub checks that block merge: `CI`
  (RSpec, RuboCop, Brakeman, markdown links), CodeQL, and a human
  Approve from `.github/CODEOWNERS`. A green markdown-link job is one
  merge requirement, not all of them.

If any applicable check has not been run, the work stays open. Do not
treat an incomplete check as a pass.

## Quality checks for UI changes

A UI PR is not done at “it looks fine on my laptop.” These six are the
quality checks:

1. **Browser check** the changed flow end to end: click, type, submit,
   navigate. A screenshot is not enough.
2. **Shared state:** if the change writes or derives data, open the other
   pages that read it (case show, search, agency, user).
3. **Empty and error:** blank search, failed save, unauthorized.
4. **Viewport:** the layout is Bootstrap 3 / `col-md-8`. Check a desktop
   width and a phone width when layout or CSS changed.
5. **Focus:** buttons, links, and form controls use `:focus-visible`
   with a 3px `$color-orange` ring (`bootstrap-mods.scss`). Do not add
   `outline: 0` or `outline: none` on new controls.
6. **Copy:** case pages are about real people. No playful empty states,
   no joke alt text. Editor photo help asks for a healthy photo of the
   person, not a mug shot. Search with no matches says so plainly.

## Architecture bar

- Rails 8 on `main`. Semver-major gems are explicit migrations, not
  weekly Dependabot.
- Search today is Elasticsearch (< 7) plus the existing case UI.
  `pg_search` and “drop Elasticsearch” stay on draft #4410 until that
  PR is a focused landing change, not a 100-file rewrite.
- Mailboxer / in-app messaging removal is draft #4411. Do not add new
  mailbox features.
- Polymorphic `linkable_type` / `linkable_id`: new `has_many :links`
  must use `as: :linkable`.
- CI (`RSpec`, `RuboCop`, `Brakeman`, markdown links) plus CodeQL is
  merge truth. Required Approve is a human reviewer (`CODEOWNERS`).

## Review quality

- One required reviewer per PR: a human listed in
  `.github/CODEOWNERS` (currently `@gktreviewer`).
- Do not request CodeRabbit, Copilot, or Factory Droid on the same PR.
  CodeRabbit's OSS plan rate-limits mid-review. Copilot comments do
  not count as Approve. Droid workflows are removed.
- Agent drafts that rewrite half the repo are closed or converted to
  draft the same week. A landing PR is the named change plus the
  smallest unlock (config, one cop, one spec helper).

## Public GitHub copy

Issue titles, pull request titles, descriptions, and comments are
public project writing. They follow the same bar as product copy.

- Complete sentences. Name the change, not the conversation that
  produced it.
- Do not quote private chat, Cursor transcripts, or first-person asides.
- Do not publish credentials, review logins, or dump-restore steps.
- A review request is a human reviewer. Do not `@coderabbitai review`.
  No status chatter.

## How we avoid missing work

Overlooked items in this cleanup came from chasing the current
blocker (one bot, one PR, one comment) instead of checking the full
surface against this file. Mitigation is a written inventory, not
memory of the last pass.

Before a hygiene or UI PR is called done, list and check:

1. **Bots and workflows** under `.github/workflows/`, not only the
   file just deleted. On-demand hooks count.
2. **Open pull requests** — ready vs draft, Dependabot vs agent
   rewrite vs real feature. Ready-list noise is closed or drafted
   the same week.
3. **Public templates** that share the change: case show, search,
   agency, organization, maps, header, footer, and the case form.
   Grep is not enough if the first match is treated as the whole job.
4. **Public GitHub copy** on the tickets this work touches: titles,
   bodies, and comments. No chat quotes, no credentials.
5. **Stored values in HTML attributes** (`alt`, `title`, `content`,
   `href`). Escape with `ERB::Util.html_escape`, or show the name as
   visible text and use an empty `alt`. Do not pass a stored record
   into `link_to`; use a path helper with the record id. `strip_tags`
   alone does not clear CodeQL stored-XSS.
6. **The quality checks above**, including empty, error, focus, and
   a browser or request-spec check. A green markdown-link job is a
   merge requirement; it does not pass the quality checks.

## Later, not now

Harbor (#4425), Hanami drafts, staff-tools, maps/photos, and a visual
redesign are later phases. They must use this review path and this
Bootstrap 3 system, or they must replace this file as part of an
explicit migration.
