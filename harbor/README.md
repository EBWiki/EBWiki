# Harbor tasks for EBWiki

[Harbor](https://github.com/harbor-framework/harbor) scores coding agents on isolated EBWiki tasks. It does not replace `make run` or RSpec. See [docs/SPIKE_HARBOR.md](../docs/SPIKE_HARBOR.md) for the spike and recommended rollout.

## Prerequisites

- Python 3.12+
- [uv](https://docs.astral.sh/uv/) or pip
- Docker (local sandbox)

```bash
uv tool install harbor
```

## Run the smoke task (oracle)

The oracle agent runs `solution/solve.sh`. This checks that Harbor, Docker, and the published app image work together. No model API key is required.

```bash
harbor run -p harbor/tasks/smoke-rails-version -a oracle
```

The smoke task pulls `ebwiki/ebwiki:latest` and writes `bundle exec rails -v` to `/tmp/rails_version.txt`.

## Run a real agent (optional)

```bash
export ANTHROPIC_API_KEY=...
harbor run -p harbor/tasks/smoke-rails-version \
  -a claude-code \
  -m anthropic/claude-sonnet-5
```

Inspect trials with `harbor view ./jobs`.

## Adding a task

```bash
harbor task init smoke-example
```

Then move the generated directory under `harbor/tasks/` and point `[environment].docker_image` at `ebwiki/ebwiki:latest` or add Compose sidecars (Postgres and Redis only; case search is `pg_search`).
