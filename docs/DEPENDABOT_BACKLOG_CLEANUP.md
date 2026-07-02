# Dependabot backlog cleanup plan (EBWiki/EBWiki)

As of 2026-07-02, open Dependabot PRs were reviewed and classified to keep routine maintenance actionable.

## Keep / actionable now

- **#4354** `rack 2.2.22 -> 2.2.23` (patch): keep open and merge when CI passes.

## Close and let Dependabot recreate later (after policy change)

These are broad grouped PRs generated under the previous policy and should be recreated under the new, smaller grouping strategy.

- **#4394** `dev-dependencies group across 1 directory with 16 updates`
- **#4357** `actions group across 1 directory with 6 updates`

## Close and convert into migration work

These are semver-major updates and should move to explicit migration issues/projects (not routine weekly maintenance).

- **#4380** `newrelic_rpm 7.2.0 -> 10.5.0`
- **#4379** `psych 4.0.6 -> 5.3.1`
- **#4377** `sitemap_generator 6.3.0 -> 7.0.1`
- **#4376** `rack-cors 1.1.1 -> 3.0.0`
- **#4375** `dotenv-rails 2.8.1 -> 3.2.0`
- **#4365** `hightop 0.6.0 -> 1.0.0`
- **#4364** `active_median 0.6.0 -> 1.0.0`
- **#4362** `chartkick 3.4.2 -> 5.2.1`

## Duplicate / superseded upgrade-path PRs

- **#4388** `puma 6.6.1 -> 7.2.1`
- **#4378** `puma 6.6.1 -> 8.0.2`

Both are migration-grade major updates for the same dependency and should be closed from routine flow, then re-opened as a single tracked migration path.

## Deferred migration candidates (explicitly not complete)

Create follow-up migration issues/projects for:

- Puma 6 -> 7/8
- New Relic agent 7 -> 10
- Psych 4 -> 5
- Rack CORS 1 -> 3
- Chartkick 3 -> 5
- Sitemap Generator 6 -> 7
- Dotenv Rails 2 -> 3
- Hightop 0 -> 1
- Active Median 0 -> 1

## Execution note

Direct PR close/relabel operations were not executed in this change set because repository permissions/tools in this environment are read-only for PR state transitions. The list above is the exact conservative cleanup action set to apply in GitHub UI or via maintainer automation.
