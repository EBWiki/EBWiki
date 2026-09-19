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

## Quality gates for UI changes

A UI PR is not done at “it looks fine on my laptop.”

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
  merge truth. CodeRabbit is the one review bot.

## Review quality

- One advisory review voice per PR: CodeRabbit. `@coderabbitai review`
  if an Approve is needed.
- Do not request Copilot review or Factory Droid on the same PR.
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
- A review request is `@coderabbitai review` only. No status chatter.

## Later, not now

Harbor (#4425), Hanami drafts, staff-tools, maps/photos, and a visual
redesign are later phases. They must use this review path and this
Bootstrap 3 system, or they must replace this file as part of an
explicit migration.
