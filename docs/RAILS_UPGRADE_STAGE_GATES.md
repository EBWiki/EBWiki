# Rails Upgrade Stage Gates

This document defines the viability checks required to move EBWiki through each Rails upgrade stage safely.

## How to use this checklist

1. Create one pull request per logical stage or substage.
2. Run the global gate commands for every stage.
3. Run stage-specific checks for the stage you are changing.
4. Do not move to the next stage unless all gate checks pass.

## Global gate commands (run at every stage)

Run these from the project root:

```bash
bundle exec rails db:prepare
bundle exec rails zeitwerk:check
bundle exec rails runner "puts :boot_ok"
bundle exec rails assets:precompile
bundle exec rspec
bundle exec rubocop
bundle exec brakeman -A --no-pager --no-exit-on-warn --no-exit-on-error
```

### Global pass criteria

- Commands complete without errors.
- Application boots (`boot_ok` output).
- No new failing specs compared to the stage baseline.
- No new critical Brakeman findings introduced by the stage change.

## Manual smoke flows (run at every stage)

Execute these in staging or a production-like local setup:

1. User sign up, sign in, sign out.
2. Case create, edit, and view.
3. Comment create on a case.
4. File upload path (CarrierWave-backed forms).
5. Search flow (Searchkick / Elasticsearch-backed pages).
6. Admin access (`/admin`) and core admin action.

### Manual pass criteria

- No 5xx responses.
- No broken JavaScript behavior in primary forms/navigation.
- No missing asset errors in browser console/network panel.

## Stage-specific viability checks

## Stage 1: Baseline stabilization

Scope:

- Lockfile and dependency consistency.
- No behavior changes.

Additional checks:

```bash
bundle check
bundle exec rails about
```

Pass criteria:

- `Gemfile` and `Gemfile.lock` are consistent.
- CI-equivalent local checks are green.

## Stage 2: Framework defaults migration (`config.load_defaults`)

Scope:

- Move defaults one step at a time (7.1 -> 7.2 -> 8.0 -> 8.1).

Additional checks per defaults bump:

```bash
bundle exec rails test:all 2>/dev/null || true
bundle exec rspec spec/requests spec/models spec/features
```

Pass criteria:

- Each defaults bump passes before applying the next.
- No unresolved deprecation warnings caused by new defaults.
- Behavior-changing settings are covered by tests.

## Stage 3: Frontend modernization (Turbo/importmap/assets)

Scope:

- Turbolinks removal and Turbo adoption.
- Remove Webpacker leftovers.
- Keep asset build stable.

Additional checks:

```bash
bundle exec rails assets:clobber assets:precompile
bundle exec rspec spec/features spec/requests
```

Pass criteria:

- Navigation and form submissions behave correctly with Turbo.
- No references to `turbolinks` or `webpacker` remain in runtime paths.
- Assets precompile in CI mode.

## Stage 4: Gem compatibility cleanup

Scope:

- Re-enable temporarily disabled gems or replace them.
- Upgrade/replace stale integrations safely.

Additional checks:

```bash
bundle exec rspec
bundle exec rails runner "Rails.application.eager_load!; puts :eager_ok"
```

Pass criteria:

- No `NameError`/autoload failures on boot or eager load.
- Re-enabled gem behavior has targeted spec coverage.

## Stage 5: Rails 8 operational features (optional)

Scope:

- Evaluate and optionally adopt Solid Queue / Solid Cache / Solid Cable.

Additional checks:

```bash
bundle exec rails runner "puts ActiveJob::Base.queue_adapter.class.name"
bundle exec rails runner "Rails.cache.write('gate_check', 'ok'); puts Rails.cache.read('gate_check')"
```

Pass criteria:

- Queue adapter, cache store, and cable adapter operate as configured.
- Operational choice (Redis-based vs Solid stack) is documented in repo docs.

## Stage 6: CI/deploy/docs alignment

Scope:

- Keep CI, Docker, and docs in sync with runtime reality.

Additional checks:

```bash
docker build -t ebwiki-upgrade-gate .
```

Pass criteria:

- CI workflow passes for all required jobs.
- Docker image builds successfully.
- README and docs reflect current Rails/Ruby versions and workflow.

## PR gate template

Copy this into each upgrade PR description:

```markdown
## Rails Upgrade Gate Checklist

- [ ] Global gate commands passed locally
- [ ] Manual smoke flows completed
- [ ] Stage-specific checks passed
- [ ] No new deprecations introduced
- [ ] Docs updated for this stage
- [ ] Rollback plan noted in PR comments
```
