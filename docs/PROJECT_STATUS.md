# EBWiki Project Status

## Recent Work

### March 3, 2026

**Pre-commit hooks and CI fixes** ([PR #4320](https://github.com/EBWiki/EBWiki/pull/4320))

- Added pre-commit hooks that run rubocop, brakeman, and rspec before each commit
- Fixed RSpec failures: users_rake_spec, versions_spec
- Aligned pre-commit Brakeman behavior with CI (non-blocking)
- Various compatibility fixes: auto_annotate_models, NullFieldsCounter, VersionsController

See [SESSION_2026-03-03_PRE_COMMIT.md](SESSION_2026-03-03_PRE_COMMIT.md) for details.

## Active Branches

| Branch | Status | Description |
|--------|--------|-------------|
| `fix/ci-issues` | In progress | CI configuration and dependency fixes |
| `feature/pre-commit-validate` | Open PR #4320 | Pre-commit hooks for rubocop, brakeman, rspec |

## Known Issues

- **Dependabot:** 69 vulnerabilities on default branch (6 critical, 24 high, 23 moderate, 16 low)
- **Temporarily disabled gems:** annotate, bullet, cloudflare-rails, cucumber-rails, redis-rails, redis-store (Rails 8.1 compatibility)
- **Pending specs:** 4 specs marked pending (xit or not yet implemented)

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) - Development setup and workflow
- [SETUP_LOCALLY.md](SETUP_LOCALLY.md) - Docker setup
- [SETUP_LOCALLY_FULLSTACK.md](SETUP_LOCALLY_FULLSTACK.md) - Full local setup
- [SESSION_2026-03-03_PRE_COMMIT.md](SESSION_2026-03-03_PRE_COMMIT.md) - March 3, 2026 session summary
