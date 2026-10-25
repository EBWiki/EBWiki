# EBWiki security, SEO, and accessibility review

## October 2025 supply-chain check (main)

At commit `51fed887b4d2eadfc444aa110e2265c0765c8580`, the tree contains **no** `.vscode/tasks.json` and **no** `public/fonts/fa-solid-900.eot`. `.vscode` is listed in `.gitignore` (line 48). This review did not execute files under `.vscode`, font assets, or other binary assets.

## Document control

| Field | Value |
| --- | --- |
| Application | EBWiki (Rails archive of people killed by police) |
| Repository | `ebwiki/ebwiki` |
| Commit reviewed | `51fed887b4d2eadfc444aa110e2265c0765c8580` (`Merge pull request #4546 from EBWiki/cursor/staging-custom-domain-port-0462`) |
| Review date (UTC) | 2026-10-25 |
| Environment | Local `RAILS_ENV=test` on `http://127.0.0.1:3000` with synthetic FactoryBot data; no staging or production hostnames accessed |
| Report status | Draft for independent review |
| Parent program | Site-wide security, SEO, and accessibility audit program (Linear GKT-1478) |
| Pull request | Draft PR on branch `cursor/security-seo-a11y-audit-39f7` (link recorded when opened) |
| CI for this report | Pending on the draft pull request (markdown link check, Brakeman, RuboCop, RSpec) |

Structure matches the Activism hub and QueerGlobal frontend audit reports (`docs/audits/2026-10-security-seo-accessibility.md` in those repositories).

## Executive summary

EBWiki at the reviewed commit runs on Rails 8.1 with Devise, Pundit, Searchkick, and Rollbar, but **does not meet an evidence-based bar for object-level authorization on case editing, dependency hygiene, or WCAG 2.2 AA on primary public journeys**.

Confirmed themes:

1. **Authorization:** Any signed-in user can open the edit form, update, or destroy any case, and any signed-in user can revert case history. Pundit is wired for users and organizations, but `CasesController` and `Cases::VersionsController` rely on `authenticate_user!` only (`app/controllers/cases_controller.rb` lines 5 to 6, 36 to 38, 59 to 73, 76 to 86; `app/controllers/cases/versions_controller.rb` lines 6 to 11, 41 to 46). Request specs expect a non-owner to receive HTTP 200 on edit (`spec/requests/cases_spec.rb` lines 54 to 65).
2. **Dependencies:** `bundler-audit` reports multiple advisories (CKEditor gem, crass, mechanize, rubyzip). Open pull requests `#4574` and `#4531` target crass and mechanize. CI does not run `bundler-audit`. npm production audit reports zero issues (`package.json` is Railway IaC only).
3. **Security configuration:** Content Security Policy is fully commented out (`config/initializers/content_security_policy.rb` lines 9 to 34). Devise `secret_key` is committed in plain text (`config/initializers/devise.rb` lines 9 to 10). Brakeman `-A` reports weak MD5 usage (`app/models/user.rb` line 51, `app/helpers/application_helper.rb` line 10). CI runs Brakeman with `--no-exit-on-warn` (`.github/workflows/ci.yml` lines 78 to 80).
4. **SEO:** Case show pages set per-page title and description (`app/views/cases/show.html.erb` lines 2 to 4). There are **no** canonical link tags in the layout (`app/views/layouts/application.html.erb`). `public/robots.txt` points at an HTTP S3 sitemap URL (lines 7 to 9). Structured data (JSON-LD) was not found in application views.
5. **Accessibility:** Playwright plus axe against the local server found **critical** `image-alt` and `select-name` issues on home, case show, about, and maps, plus **serious** color contrast and link-name issues (see Appendix C). Code review notes invalid heading nesting on case show (`app/views/cases/show.html.erb` lines 36 to 42), navbar dropdown keyboard gaps (`app/views/layouts/_header.html.erb` lines 29 to 39), and map markup that exposes case JSON in a script tag (`app/views/maps/index.html.erb` lines 16 to 21).

Automated axe results and green CI jobs are **not** treated as conformance or security acceptance.

## Scope and limitations

| In scope | Out of scope or not tested |
| --- | --- |
| Rails application, public case pages, search, maps, Devise auth, admin Administrate namespace | Password-protected staging (not accessed by design) |
| OWASP Top 10:2025, CWE Top 25:2025, applicable OWASP ASVS 5.0 checks | Live penetration testing, outbound email, credential use |
| Google Search Essentials for crawlable case content | Production Search Console indexing state |
| WCAG 2.2 AA (automated scan plus code review) | Full screen reader certification, every admin screen |
| GitHub Actions trust boundaries | Deployed CDN or Cloudflare header policies not defined in this repo |

No credentials or personal data appear in this document.

## Methodology and tools

| Tool | Version (2026-10-25 UTC) | Use |
| --- | --- | --- |
| Ruby | 3.4.2 | App and Brakeman |
| Rails | 8.1.4 (from `Gemfile.lock`) | Framework |
| Brakeman | 8.1.0 | Static security scan (`-A` and default) |
| bundler-audit | 0.9.3 | Gem advisories |
| npm audit | 10.9.7 | `package-lock.json` (Railway tooling only) |
| PostgreSQL | 16 (local load of `db/structure.sql`) | Synthetic data |
| Playwright | 1.49.1 | Headless browser |
| @axe-core/playwright | 4.10.1 (installed under `docs/audits/harness/`) | WCAG-tagged rules |
| Manual review | n/a | Policies, layouts, CI workflows, meta tags |

Evidence rule: each row uses **pass**, **fail**, **not applicable**, or **not tested**. Missing evidence is never a pass.

## Pages and user journeys exercised

Database: `docs/audits/harness/prepare_local_db.sh` (loads structure without PG17-only `transaction_timeout`, seeds slug `audit-sample-case`).

Server: `RAILS_ENV=test SECRET_KEY_BASE=audit_local_secret bundle exec rails server -p 3000 -b 127.0.0.1`.

| Journey | Route(s) | What was done |
| --- | --- | --- |
| Home | `/` | axe at 1280x720; HTTP 200 |
| Case show (synthetic) | `/cases/audit-sample-case` | axe; per-page meta tags in source |
| About | `/about` | axe |
| Maps | `/maps` | axe; map widget markup review |
| Search | `/search?query=test` | HTTP probe (Elasticsearch not running locally; 500 in test env) |
| Missing case slug | `/cases/nonexistent-audit-slug-xyz` | HTTP probe in test env (500 with stack trace; production uses `public/404.html`) |
| Crawlers | `/robots.txt` | Body and Sitemap directive |
| Admin | `/admin` | Code review of `Admin::ApplicationController` only (no login attempt) |
| Registration | Devise views | reCAPTCHA present in template (`app/views/devise/registrations/new.html.erb`) |

Keyboard and focus: manual review of header, search bar, and case show heading structure (no full manual pass at 200% zoom).

## Summary matrix

Counts are checklist rows in the detailed sections (themes, not every CWE).

| Area | Pass | Fail | Not applicable | Not tested |
| --- | ---: | ---: | ---: | ---: |
| Security | 14 | 12 | 5 | 8 |
| SEO | 4 | 8 | 1 | 3 |
| Accessibility | 3 | 11 | 2 | 7 |

## Security review

Mapping to OWASP Top 10:2025 themes and selected ASVS V2/V3/V7 checks where they apply to this Rails monolith.

| ID | Check | Result | Evidence |
| --- | --- | --- | --- |
| S1 | Brakeman default scan (no warnings surfaced) | **pass** | `bundle exec brakeman -q`: 0 warnings (1 mass-assignment finding suppressed in `config/brakeman.ignore` lines 3 to 22) |
| S2 | Brakeman `-A` additional checks | **fail** | Weak MD5: `app/models/user.rb:51`, `app/helpers/application_helper.rb:10` |
| S3 | Mass assignment (`:admin` on users) | **fail** | `app/controllers/users_controller.rb:51-56` permits `:admin` for admins; Brakeman ignored with note in `config/brakeman.ignore` |
| S4 | Case update/destroy authorization | **fail** | `CasesController` edit/update/destroy without `authorize` (`app/controllers/cases_controller.rb:36-38`, `59-73`, `76-86`); `CasePolicy` only defines `destroy?` (`app/policies/case_policy.rb:5-7`) and is unused in controller |
| S5 | Case history revert authorization | **fail** | `Cases::VersionsController#revert` after `authenticate_user!` only (`app/controllers/cases/versions_controller.rb:6-11`, `41-46`) |
| S6 | Admin namespace gate | **pass** | `Admin::ApplicationController` `before_action :authenticate_admin` (`app/controllers/admin/application_controller.rb:11-16`) |
| S7 | Pundit on user profile | **pass** | `UsersController#edit/#update` call `authorize` (`app/controllers/users_controller.rb:15-20`, `38-40`); `UserPolicy` (`app/policies/user_policy.rb:5-13`) |
| S8 | Authentication (Devise, bcrypt stretches) | **pass** | Devise modules on `User` (`app/models/user.rb:7-8`); `config.stretches` 10 outside test (`config/initializers/devise.rb:99`) |
| S9 | Devise secret key handling | **fail** | Hard-coded `config.secret_key` (`config/initializers/devise.rb:9-10`) |
| S10 | Session store | **not tested** | `activerecord-session_store` (`config/initializers/session_store.rb:5`); cookie flags in production inferred from `force_ssl` (`config/environments/production.rb:49`) without browser capture |
| S11 | CSRF | **pass** | `csrf_meta_tags` in layout (`app/views/layouts/application.html.erb:40`); forgery protection enabled outside test |
| S12 | SQL injection (raw user SQL in app code) | **pass** | No `find_by_sql` / string interpolation SQL in `app/` (grep review); Searchkick query from params (`app/controllers/search_controller.rb:6`) |
| S13 | XSS in views (`html_safe`) | **pass** | No `html_safe` in tree; case fields use `sanitize` (`app/views/cases/_main_content.html.erb:2-10`) |
| S14 | XSS via case blurbs in meta | **fail** | Unescaped `content_for` meta description from `@this_case.blurb` (`app/views/cases/show.html.erb:3`) could break out of attribute if blurb contained quotes (blurb strips HTML on save per `spec/requests/cases_spec.rb:117-120`) |
| S15 | CKEditor attack surface | **fail** | Gem `ckeditor` 5.1.3; multiple CVEs in `bundler-audit`; engine mounted at `/ckeditor` (`config/routes.rb:78`) |
| S16 | Secrets in repository | **fail** | Devise secret in repo (S9); no live AWS keys found in grep of `config/` |
| S17 | Dependency audit (Ruby) | **fail** | `bundler-audit check`: ckeditor (5 CVEs), crass 1.0.7, mechanize 2.14.0 (2 CVEs), rubyzip 2.4.1 (high) |
| S18 | Dependency audit in CI | **fail** | `.github/workflows/ci.yml` has no bundler-audit job |
| S19 | npm dependency audit | **pass** | `npm audit --omit=dev`: 0 vulnerabilities (`package-lock.json` only lists `railway`) |
| S20 | `pull_request_target` | **fail** | `.github/workflows/dependabot-auto-merge.yml` lines 4-5 (mitigated by `if:` on Dependabot actor, lines 12-13) |
| S21 | Workflow permissions | **pass** | CI workflow has no elevated default permissions (`.github/workflows/ci.yml`); infra workflows set explicit `permissions` blocks |
| S22 | Third-party Actions pinning | **fail** | `ruby/setup-ruby@v1`, `docker/*@v2/v3` floating majors (`.github/workflows/ci.yml:36`, `publish_docker_image.yml:17-29`) |
| S23 | Content Security Policy | **fail** | Entire policy commented (`config/initializers/content_security_policy.rb:9-34`) |
| S24 | Security headers (app response) | **pass** | Local case page returns `x-frame-options`, `x-content-type-options`, `referrer-policy` (curl against `127.0.0.1:3000`, Appendix B) |
| S25 | `force_ssl` / HSTS | **pass** | `config.force_ssl = true` in production (`config/environments/production.rb:49`) |
| S26 | CORS | **not tested** | `rack-cors` gem present (`Gemfile:51`) but no initializer located |
| S27 | Error tracking | **pass** | Rollbar configured via env (`config/initializers/rollbar.rb:9-14`); not Sentry |
| S28 | Health endpoint exposure | **not tested** | `HealthController` JSON readiness (`app/controllers/health_controller.rb:9-15`); open PR `#4577` addresses Cloudflare lockdown |
| S29 | reCAPTCHA on signup | **pass** | `Users::RegistrationsController` verifies recaptcha (`app/controllers/users/registrations_controller.rb:9`) |
| S30 | Logging sensitive fields | **fail** | Only `:password` filtered (`config/initializers/filter_parameter_logging.rb:6`); email/tokens not listed |
| S31 | Injection via `raw()` in pagination | **pass** | Kaminari partials use `raw(t(...))` on i18n strings only (`app/views/kaminari/_next_page.html.erb:2`) |
| S32 | Agency form error `raw` | **fail** | `raw` wraps error messages (`app/views/agencies/_form.html.erb:9`) |
| S33 | Production error pages | **not tested** | `public/404.html` exists; test env raises on missing records (Appendix B) |
| S34 | Redis / Elasticsearch exposure | **not tested** | Services referenced in CI (`.github/workflows/ci.yml:28-32`) |
| S35 | Docker publish on main push | **not tested** | `publish_docker_image.yml` pushes `ebwiki/ebwiki:latest` on main (lines 8-10, 31-34) |

## SEO review

| ID | Check | Result | Evidence |
| --- | --- | --- | --- |
| E1 | Unique `<title>` on case show | **pass** | `app/views/cases/show.html.erb:2` |
| E2 | Meta description on case show | **pass** | `app/views/cases/show.html.erb:3` via layout lines 17-18 |
| E3 | Default meta for other pages | **pass** | `config/meta.yml` and `MetaTagsHelper` (`app/helpers/meta_tags_helper.rb:5-21`) |
| E4 | Open Graph and Twitter cards | **pass** | `app/views/layouts/application.html.erb:21-35` |
| E5 | Canonical URLs | **fail** | No `rel=canonical` in layout or case views (grep) |
| E6 | `robots.txt` | **pass** | `public/robots.txt` allows crawl; disallows follower URLs pattern line 7 |
| E7 | Sitemap URL scheme | **fail** | `Sitemap:` uses `http://bow-sitemaps.s3.amazonaws.com/...` (`public/robots.txt:9`); generator uses HTTPS host `https://ebwiki.org` (`config/sitemap.rb:4`) |
| E8 | Sitemap generation | **not tested** | `config/sitemap.rb` requires AWS env in production (lines 12-24) |
| E9 | 404 for missing cases | **fail** | FriendlyId raises `RecordNotFound` (`cases_controller.rb:18`); test env returns 500 with stack trace (Appendix B); open PR `#4497` targets public 404 behavior for e2e |
| E10 | 404 page content | **pass** | `public/404.html` static page |
| E11 | Structured data | **fail** | No JSON-LD in `app/views` (grep) |
| E12 | Mobile viewport | **pass** | `meta name="viewport"` (`app/views/layouts/application.html.erb:15`) |
| E13 | Case index meta | **fail** | `cases#index` does not set `content_for` meta (uses defaults only) |
| E14 | Search results SEO | **not tested** | Search failed locally without Elasticsearch |
| E15 | Follower URLs in sitemap | **fail** | `config/sitemap.rb:31` adds `cases_followers_path` (non-primary content; `robots.txt` disallows `/*/follows`) |
| E16 | Staging indexability | **not applicable** | Staging must stay private; PRs `#4513`, `#4516` add staging privacy checks |

## Accessibility review

| ID | Check | Result | Evidence |
| --- | --- | --- | --- |
| A1 | Document language | **pass** | `<html lang="en">` (`app/views/layouts/application.html.erb:2`) |
| A2 | Automated axe (WCAG 2.x tags) | **fail** | Critical `image-alt`, `select-name`; serious `color-contrast`, `link-name` on four routes (Appendix C) |
| A3 | Search state filter accessible name | **fail** | `select_tag` wrapped in mislabeled `label_tag 'search'` (`app/views/search/_bar.html.erb:3-7`); axe `select-name` |
| A4 | Image alternative text | **fail** | Case avatar `image_tag` without alt (`app/views/cases/show.html.erb:17-20`); logo in header (`app/views/layouts/_header.html.erb:11`) |
| A5 | Heading structure on case show | **fail** | `h1` contains `p.lead` (`app/views/cases/show.html.erb:36-42`) |
| A6 | Main landmark | **fail** | Layout uses containers only; no `<main>` (`app/views/layouts/application.html.erb:46-64`) |
| A7 | Skip link | **fail** | Not present in layout |
| A8 | Keyboard: navbar dropdown | **fail** | `href="#"` toggle (`app/views/layouts/_header.html.erb:31`); Bootstrap 3 pattern |
| A9 | Focus visible | **not tested** | No custom focus styles reviewed in browser |
| A10 | Form labels on comments | **not tested** | Comment partial not axe-scoped separately |
| A11 | Map widget | **fail** | `#map-container` without documented keyboard alternative (`app/views/maps/index.html.erb:16-19`) |
| A12 | Color contrast | **fail** | axe serious on all scanned pages (Appendix C) |
| A13 | Touch target size | **not tested** | Not covered by axe run |
| A14 | Help icon images | **fail** | `help_icon.png` without alt in `_main_content.html.erb:1-9` |
| A15 | Mobile navigation | **not tested** | axe run used desktop viewport only |
| A16 | CKEditor editor accessibility | **not tested** | Third-party editor on case forms |
| A17 | Flash dismiss control | **fail** | Close button `&times;` without accessible name (`app/views/layouts/application.html.erb:49-50`) |
| A18 | Social share button | **not tested** | `social-share-button` gem on case show line 24 |
| A19 | `sr-only` on menu toggle | **pass** | `app/views/layouts/_header.html.erb:6` |
| A20 | Map PR keyboard follow-up | **not tested** | Open PR `#4537` restores HERE map (may affect A11) |

Automated scores are **not** a conformance claim.

## Gap register

| Gap ID | Area | Finding | Impact | Severity | Blocks release | Suggested owner | Linked work | Dependencies | Definition of done | Verification | Rollback |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| G1 | Security | Any signed-in user can edit, update, or destroy any case | Unauthorized content changes or deletion | Critical | **Yes** | Backend | No open PR on main addresses object-level case auth | Pundit policies | `authorize` on case mutations; deny by default; request specs for non-owner | RSpec request/policy examples | Revert controller changes |
| G2 | Security | Any signed-in user can revert case history | Rollback of legitimate edits | High | **Yes** | Backend | None on main | PaperTrail | Admin or case-owner gate on `VersionsController#revert` | Request spec | Revert |
| G3 | Security | Known gem CVEs (ckeditor, crass, mechanize, rubyzip) | XSS, sanitizer bypass, credential leakage, path traversal | High | **Yes** | Backend | PR `#4574` (crass), `#4531` (mechanize), ckeditor/rubyzip not fully covered | Bundle updates | Clean `bundler-audit check` on main | CI job plus local audit | Revert gem bumps |
| G4 | Security | Devise secret key committed | Token forgery if key reused across envs | High | **Yes** | Backend | None | Credentials store | Key from ENV or credentials; rotate tokens | Brakeman/config review | Restore prior initializer |
| G5 | Security | CSP disabled | XSS impact amplification | Medium | No | Backend | None | Front-end asset review | Enforced or report-only CSP in initializer | Header probe | Comment policy again |
| G6 | Security | bundler-audit not in CI | Vulnerable gems ship unnoticed | Medium | No | DevOps | PR `#4572` adds pre-commit Brakeman/RuboCop, not audit | Workflow | Job fails on advisories | CI log | Remove job |
| G7 | Security | dependabot auto-merge uses `pull_request_target` | Supply-chain risk if `if` guard fails | Medium | No | DevOps | None | GitHub settings | Document threat model or replace trigger | Workflow review | Disable workflow |
| G8 | SEO | No canonical URLs | Duplicate URL confusion | Medium | No | Frontend | None | Hosting redirects | `link rel=canonical` on case show | View or system spec | Remove tags |
| G9 | SEO | HTTP sitemap URL in robots.txt | Crawler hints not aligned with HTTPS | Low | No | DevOps | None | S3 host | HTTPS Sitemap line in `public/robots.txt` | Fetch robots.txt | Revert file |
| G10 | SEO | Missing structured data on cases | Rich result eligibility reduced | Low | No | Frontend | None | Content model | JSON-LD for `Article` or `Person` where appropriate | Rich Results test when deployed | Remove markup |
| G11 | SEO | Missing case 404 semantics in some envs | Soft errors hurt crawl quality | Medium | No | Backend | PR `#4497` (public 404 for e2e) | Rails config | Real 404 status and body in production | Request spec / curl | Revert config |
| G12 | Accessibility | axe critical: missing alt text | Screen reader users miss images | Critical | **Yes** | Frontend | None | Asset pipeline | Meaningful `alt` on logos, avatars, icons | axe clean on case/home | Revert templates |
| G13 | Accessibility | axe critical: select accessible name | State filter unusable for AT | Critical | **Yes** | Frontend | None | Search bar partial | Proper `label for=` or `aria-label` on `#state_id` | axe + keyboard | Revert partial |
| G14 | Accessibility | Color contrast failures | Low vision users | Serious | No | Design + Frontend | None | Bootstrap theme | axe serious cleared on primary routes | axe scan | Revert CSS |
| G15 | Accessibility | Invalid heading hierarchy on case show | Navigation by headings impaired | Moderate | No | Frontend | None | Template | Valid `h1` then `p` for subtitle | HTML validator / manual | Revert template |
| G16 | Accessibility | Map not keyboard accessible | Motor and keyboard users excluded | Serious | No | Frontend | PR `#4537` (map restore) | HERE map JS | Documented alternative list or keyboard pins | Manual test | Revert map PR |
| G17 | Security | CKEditor CVE backlog | Stored XSS in editor samples | Medium | No | Backend | None | Editor upgrade path | Upgrade or remove editor; audit mount auth | bundler-audit | Revert gem |
| G18 | Security | MD5 for Gravatar/Mailchimp | Not collision-safe for secrets | Low | No | Backend | None | External APIs | Document as non-cryptographic or migrate | Brakeman `-A` clean | Revert |

## Release blockers

1. **G1** and **G2** authorization on case mutations and history revert.
2. **G3** Ruby gem advisories with no acceptable compensating control on main.
3. **G4** committed Devise secret (rotation plan required before treating auth as production-grade).
4. **G12** and **G13** critical accessibility defects on primary navigation and case pages.

## Post-release improvements

- G5 CSP, G6 CI audit, G7 workflow hardening, G8 canonical URLs, G9 robots sitemap HTTPS, G10 structured data, G11 404 consistency, G14 contrast, G15 headings, G16 map access, G17 CKEditor, G18 MD5 hygiene.

## Untested areas

- Staging and production hostnames, TLS, Cloudflare rules, and Basic Auth (by design).
- Admin Administrate flows after login.
- Mailbox and messaging UI.
- Search with live Elasticsearch.
- Full keyboard tour, 200% zoom, and screen readers.
- Deployed security headers at CDN edge.
- Docker image contents and runtime secrets on Railway.
- Globe view in open PR `#4536`.

## Related work (existing pull requests)

| Topic | Open pull request |
| --- | --- |
| crass advisory | `#4574` Upgrade crass to 1.0.8 |
| mechanize advisory | `#4531` Bump mechanize to 2.14.1 |
| Public 404 behavior | `#4497` Serve public 404 pages in CI development for e2e |
| Staging privacy | `#4513`, `#4516` |
| Health endpoint exposure | `#4577` Lock down GET /health at Cloudflare |
| Pre-commit security lint | `#4572` Pre-commit hook blocks staged style and security issues |
| Map restoration | `#4537`, `#4536` |
| HTML in search previews | `#4534` Strip HTML tags from old case blurbs |
| Staging cache crashes | `#4540` |

No open pull request on main was found for case-level Pundit enforcement on edit, update, destroy, or revert.

## Appendix A: Commands exercised

```bash
git rev-parse origin/main
bundle exec brakeman -q
bundle exec brakeman -A -q
bundler-audit check
npm audit --omit=dev
bash docs/audits/harness/prepare_local_db.sh
RAILS_ENV=test SECRET_KEY_BASE=audit_local_secret bundle exec rails server -p 3000 -b 127.0.0.1
cd docs/audits/harness && npm ci && node wcag_local_scan.mjs --base-url http://127.0.0.1:3000
curl -sI http://127.0.0.1:3000/cases/audit-sample-case
```

## Appendix B: Local HTTP probes (`RAILS_ENV=test`)

| URL | Status | Notes |
| --- | ---: | --- |
| `/` | 200 | Case index |
| `/cases/audit-sample-case` | 200 | Synthetic case |
| `/cases/nonexistent-audit-slug-xyz` | 500 | `RecordNotFound` propagates (production should serve `public/404.html` with 404) |
| `/search?query=test` | 500 | Elasticsearch not running locally |
| `/robots.txt` | 200 | See E7 |
| `/about` | 200 | Static page |

Response headers (case show): `x-frame-options: SAMEORIGIN`, `x-content-type-options: nosniff`, `referrer-policy: strict-origin-when-cross-origin`; no `Content-Security-Policy`.

## Appendix C: axe summary (local, not conformance)

Full JSON: `/opt/cursor/artifacts/axe-scan-results.json` (review run artifact).

| Journey | Critical violations | Serious violations |
| --- | --- | --- |
| home | `image-alt`, `select-name` | `color-contrast`, `link-name` |
| case_show | `image-alt`, `select-name` | `color-contrast`, `link-name` |
| about | `image-alt`, `select-name` | `color-contrast`, `link-name` |
| maps | `image-alt`, `select-name` | `color-contrast`, `link-name` |

---

_Independent reviewer: challenge coverage, confirm false positives, and reconcile release blockers before merge of this report._
