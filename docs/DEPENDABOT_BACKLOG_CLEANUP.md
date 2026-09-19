# Dependabot backlog cleanup plan (EBWiki/EBWiki)

Updated 2026-09-19. The July 2026 inventory is superseded. Routine grouped updates
are no longer leftover noise; the remaining work is two mergeable PRs plus deferred
semver-major migrations.

## Land now

- **#4423** bundler-dev (replacement for closed #4398): faker, mock_redis, rake,
  rspec-rails, rubocop, rubocop-rails, annotaterb, brakeman, rails_real_favicon,
  selenium-webdriver, webmock, standard. Disables `Rails/StrongParametersExpect`
  so the bump can land; the `params.expect` migration is a later change.
- **#4421** Puma 6.6.1 → 7.2.1: this is the tracked Puma 6 → 7 path. Keep it
  (do not close as routine Dependabot). It is a semver-major security bump, so
  auto-merge will not take it. Copilot added a `github.actor == 'dependabot[bot]'`
  guard so auto-merge does not run after a maintainer push.

  Deployment check: `config/puma.rb` does not enable PROXY protocol v1.
  CVE-2026-47736 and CVE-2026-47737 only apply when that protocol is enabled.

## Already landed or closed

- **#4422** bundler-runtime — merged
- **#4398** bundler-dev — closed, replaced by #4423
- **#4400** older bundler-security group — superseded by #4421
- **#4354** rack 2.2.22 → 2.2.23 — closed
- **#4388** / **#4378** older Puma 7 / 8 Dependabot PRs — closed; #4421 is the
  single Puma 7 track. Puma 7 → 8 stays deferred.
- **#4424** Copilot draft duplicate of the Puma 7.2.1 bump — close as duplicate
  of #4421

## Still deferred (explicit migration, not weekly Dependabot)

- New Relic agent 7 → 10
- Psych 4 → 5
- Rack CORS 1 → 3
- Chartkick 3 → 5
- Sitemap Generator 6 → 7
- Dotenv Rails 2 → 3
- Hightop 0 → 1
- Active Median 0 → 1
- Puma 7 → 8
