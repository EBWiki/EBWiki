# Harbor tasks for EBWiki

[Harbor](https://github.com/harbor-framework/harbor) scores coding agents on isolated EBWiki tasks. It does not replace `make run` or RSpec. See [docs/SPIKE_HARBOR.md](../docs/SPIKE_HARBOR.md) for the spike and recommended rollout.

## Prerequisites

- Python 3.12+
- [uv](https://docs.astral.sh/uv/) or pip
- Docker (local sandbox)

```bash
uv tool install harbor
```

## Dataset

`harbor/registry.json` defines the `ebwiki-dev` dataset: smoke, boot, and spec-fix. Paths are in-repo. Run the folder or the registry:

```bash
harbor run -p harbor/tasks -a oracle
harbor run -p harbor/registry.json -a oracle
```

No paid model is required for oracle.

## Tasks

| Task | What it proves |
| --- | --- |
| `tasks/smoke-rails-version` | Image pull + `rails -v`. No database. |
| `tasks/boot-rails` | Eval image + Compose Postgres 17 / Redis 7. `rails runner` writes the app class. |
| `tasks/fix-failing-spec` | Agent (or oracle) makes a red RSpec example green. |

Shared Compose and the eval Dockerfile live in [`environments/ebwiki-dev/`](environments/ebwiki-dev/). Tasks that need sidecars copy those files into their own `environment/`. Case search is `pg_search` — do not add Elasticsearch.

## Run the smoke task (oracle)

The oracle agent runs `solution/solve.sh`. This checks that Harbor, Docker, and the published app image work together. No model API key is required.

```bash
harbor run -p harbor/tasks/smoke-rails-version -a oracle
```

The smoke task uses `ebwiki/ebwiki:latest`. Build it locally with `docker compose build` (or `make build`) so you are not depending on a stale Docker Hub image. It writes `bundle exec rails -v` to `/tmp/rails_version.txt`.

## Boot and spec-fix (oracle)

These tasks build the eval image (test gem group) and start Postgres + Redis:

```bash
harbor run -p harbor/tasks/boot-rails -a oracle
harbor run -p harbor/tasks/fix-failing-spec -a oracle
```

Seeds only. Never restore a production dump into a Harbor sandbox.

CI validates task layout and `registry.json` on `harbor/**` changes. It does **not** run `harbor run` (Docker + image pull) and does **not** call paid agents.

## Run a real agent (last)

Only after every oracle score is `1`:

```bash
export ANTHROPIC_API_KEY=...
harbor run -p harbor/tasks/fix-failing-spec \
  -a claude-code \
  -m anthropic/claude-sonnet-5
```

Inspect trials with `harbor view ./jobs`.

## Adding a task

```bash
harbor task init smoke-example
```

Then move the generated directory under `harbor/tasks/`. For image-only tasks, set `[environment].docker_image = "ebwiki/ebwiki:latest"`. For database tasks, copy `environments/ebwiki-dev/` into the task `environment/` (Postgres and Redis only).

Add the task path to `registry.json`.
