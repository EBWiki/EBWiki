# Bootstrap 3 usage inventory (GKT-909)

Spike snapshot for **EBWiki `main` at `302c9a1d`** (2026-10-05). This document inventories Bootstrap 3 (B3) markers and migration risk; it does **not** define Bootstrap 5 scope or sequencing.

**Product decision owner:** Mark — scope and GO for Bootstrap 5 remain **[GKT-625](https://linear.app)** (human decision). GKT-909 is evidence only.

## Executive summary

EBWiki on `main` is a **Sprockets + bootstrap-sass 3.x** app. There is **no** Webpack/`app/javascript/packs` tree. B3 surface area is moderate: roughly **31** ERB templates touch grid or Bootstrap utility classes; **fewer than ~15** files carry B3-specific breaking markers (panels, glyphicons, `btn-default`, `data-toggle`, `pull-*`, `col-xs-*`). The largest view hotspot is **`static/instructions.html.erb`** (accordion built from `panel-group` / `panel-collapse`). Pipeline coupling includes **`bootstrap3-datetimepicker-rails`**, **`select2-rails`** (Bootstrap 3 theme import), **`simple_form_bootstrap`**, and custom **`bootstrap-mods.scss`**.

## Scan method

From repo root (`302c9a1d`), searched `app/`, `config/`, and first-party assets (excluded vendor `bootstrap-datetimepicker` copies where noted):

```bash
# Representative marker scans (file counts under app/ + config/, excluding datetimepicker vendor noise)
rg -l 'glyphicon' app config
rg -l 'panel-' app
rg -l '\bwell\b' app
rg -l 'pull-right|pull-left' app
rg -l 'hidden-xs|hidden-sm' app
rg -l 'data-toggle' app
rg -l 'btn-default' app
rg -l 'col-xs-' app
rg -l 'navbar-default' app
rg -l 'img-responsive' app
rg -l 'has-error|help-block' app config
```

Sample hits (2026-10-05):

| Marker | Approx. files (app/config) | B5 note |
|--------|------------------------------|---------|
| `glyphicon` | 1 (`app/inputs/date_picker_input.rb`) | Replace with SVG/icon font; datetimepicker UI |
| `panel-*` / `panel-group` | 6 views + `.panel-footer` in SCSS | **Cards** + collapse component; JS API change |
| `well` | 8 (views + `forms.scss` + mail helper) | **Removed** — use utilities / card |
| `pull-left` / `pull-right` | 4 views | **`float-start` / `float-end`** |
| `hidden-xs` / `hidden-sm` | 0 | Already absent on `main` |
| `data-toggle` / `data-target` | 7 (header, cases, instructions, JS shims) | **`data-bs-toggle` / `data-bs-target`**; drop jQuery plugin pattern |
| `btn-default` | 6 | **`btn-secondary`** |
| `col-xs-*` | 4 | **`col-*`** (xs breakpoint merged) |
| `navbar-default` | 1 (`layouts/_header.html.erb`) | **`navbar` + `navbar-light` / background utilities** |
| `img-responsive` | 7 views + override in `cases.scss` | **`img-fluid`** |
| `has-error` / `help-block` / `control-label` | 2 (`simple_form_bootstrap.rb` + forms) | **`is-invalid`**, **`form-text`**, **`form-label`** |

Combined pattern density in views (single pass, illustrative):

```bash
rg -c 'data-toggle|panel |panel-|btn-default|glyphicon|pull-right|pull-left|well |img-responsive|col-xs-' app/views --glob '*.erb' | sort -t: -k2 -nr | head -10
```

Top files by hit count: `static/instructions.html.erb` (33), `conversations/show.html.erb` (7), `cases/_form.html.erb` (7), `layouts/_header.html.erb` (5), `cases/show.html.erb` (5).

## Hotspot table

| Area | Path(s) | B3 patterns | Risk | Notes |
|------|---------|-------------|------|-------|
| Guidelines / accordion | `app/views/static/instructions.html.erb` | `panel-group`, `panel-collapse`, `data-toggle="collapse"` | **High** | Largest single template; accordion semantics change in B5 |
| Global chrome | `app/views/layouts/_header.html.erb` | `navbar-default`, `navbar-toggle`, `data-toggle` dropdown/collapse | **High** | Every page; mobile nav + account menu |
| Footer layout | `app/views/layouts/_footer.html.erb`, `application.scss` | `panel-footer`, `pull-right` | **Medium** | Footer positioned via `.panel-footer` custom CSS |
| Mailbox / conversations | `mailbox/_folder_view.html.erb`, `conversations/show.html.erb`, `users/show.html.erb` | `panel panel-default`, `panel-body` | **Medium** | Messaging UI blocks |
| Case CRUD / show | `cases/_form.html.erb`, `cases/show.html.erb`, thumbnails | `img-responsive`, `data-toggle`, `btn-default`, `pull-right` | **Medium** | Core product surfaces |
| Date picking | `app/inputs/date_picker_input.rb`, `bootstrap3-datetimepicker-rails` | `glyphicon-calendar`, `input-group-btn`, `btn-default` | **High** | Gem is B3-specific; needs replacement (e.g. Stimulus + flatpickr/tempus) |
| Forms framework | `config/initializers/simple_form_bootstrap.rb` | `btn-default`, `has-error`, `help-block`, `control-label`, `form-group` | **High** | Touches all SimpleForm views; initializer rewrite |
| Button / brand SCSS | `app/assets/stylesheets/bootstrap-mods.scss`, `application.scss` | B3 button selectors, `.open > .dropdown-toggle`, navbar breakpoint hack | **Medium** | Custom overrides assume B3 class names |
| Select2 | `application.scss` `@import "select2-bootstrap"` | B3-themed select2 | **Medium** | Needs B5-compatible theme or drop theme |
| Legacy JS shims | `app/assets/javascripts/tooltip.js`, `popover.js` | Assume Bootstrap 3 jQuery plugins | **Medium** | Remove or replace when moving off `bootstrap-sprockets` |

## Gem and asset pipeline

| Component | Location | Role |
|-----------|----------|------|
| `bootstrap-sass` (≥ 3.4.1) | `Gemfile`, `application.scss`, `application.js` | Core B3 CSS/JS via Sprockets |
| `bootstrap3-datetimepicker-rails` | `Gemfile`, vendor + requires | Date/time UI tied to B3 |
| `jquery-rails` | `Gemfile`, `application.js` | Required by B3 JS plugins |
| `select2-rails` + `select2-bootstrap` | `Gemfile`, SCSS import | Select styling for B3 |
| `simple_form` + `simple_form_bootstrap.rb` | `config/initializers/` | Form wrappers and error classes |
| `social-share-button` | SCSS import | Third-party styles alongside B3 |
| Custom | `bootstrap-mods.scss`, `forms.scss`, `cases.scss` | Overrides (`.img-responsive`, `.panel-footer`, wells) |

**Not present on `main`:** `app/javascript/packs`, importmap-first pipeline, Propshaft-only migration (see draft **EBWiki PR #4406** — out of scope for this spike’s baseline).

## S / M / L slice recommendations (for GKT-625 planning only)

These are **candidate** work slices, not approved scope.

### Small (S) — docs / low-risk class renames

- Replace `img-responsive` → `img-fluid` in case/search/user thumbnails (7 templates + `cases.scss`).
- Replace `pull-right` / `pull-left` with float utilities (4 templates).
- Rename `btn-default` → `btn-secondary` in isolated views (`maps/index`, `comments/_add_comment_form`, etc.) **after** B5 CSS is available (noop on B3).

### Medium (M) — shared layout and panels

- Refactor `static/instructions.html.erb` accordion to B5 collapse/cards.
- Migrate `layouts/_header.html.erb` navbar to B5 markup and `data-bs-*` attributes.
- Convert mailbox/conversation `panel-*` blocks to cards.
- Update `simple_form_bootstrap.rb` to B5 wrapper API.

### Large (L) — pipeline and dependencies

- Replace `bootstrap-sass` + Sprockets JS with chosen B5 delivery (gem, npm, or importmap) per GKT-625.
- Remove/replace `bootstrap3-datetimepicker-rails` and `DatePickerInput` glyphicon button.
- Reconcile `select2-bootstrap`, Cocoon, CKEditor, and any jQuery plugins with post-jQuery Bootstrap 5 JS.
- Revisit `bootstrap-mods.scss` and navbar breakpoint comments in `application.scss`.

## Explicit out of scope (GKT-909)

- Implementing Bootstrap 5 or changing runtime CSS/JS on `main`.
- Deciding migration order, budget, or “big bang” vs phased — **GKT-625 (Mark)**.
- Merging or rebasing **EBWiki PR #4406** (Rails 8 / Propshaft / B5 draft); treat as a separate line of work that would supersede much of this inventory when landed.
- Visual redesign, archive-wide SCSS cleanup, or unrelated gem upgrades.
- Playwright/e2e matrix or full RSpec suite for migration (only the optional inventory path spec ships with this spike).

## Related tickets

| Ticket | Relationship |
|--------|----------------|
| **GKT-909** | This inventory spike (Done when doc + draft PR + prompts land). |
| **GKT-625** | Human GO on Bootstrap 5 scope and approach. |

**Ticket Done ≠ parent Done:** closing GKT-909 does not complete GKT-625 or any migration parent epic.

## Evidence anchor

- Baseline SHA: `302c9a1d` (`Bump the bundler-dev group… #4448`).
- Inventory path: `docs/bootstrap/BOOTSTRAP3_INVENTORY.md` (this file).
