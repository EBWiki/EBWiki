# Spike: Attach Harbor Framework to EBWiki for development

**Status:** recommendation, not implemented in production workflows  
**Harbor:** [harbor-framework/harbor](https://github.com/harbor-framework/harbor) ([docs](https://docs.harborframework.com/))  
**Question:** Should EBWiki use Harbor as a development tool, and if so, how?

## Recommendation

Yes — attach Harbor as an **agent evaluation harness** next to EBWiki, not inside the Rails app.

Harbor is the wrong tool for replacing `make run`, RSpec, or Heroku deploys. It is the right tool for answering: *can a coding agent complete a real EBWiki contributor task in a reproducible sandbox?*

Use it to:

- Score agents (Claude Code, Codex, Cursor CLI, OpenHands, and others Harbor already integrates) on EBWiki-specific work
- Keep those tasks versioned beside the app, the way we version RSpec
- Catch “the agent can pass CI on a toy repo but fails on our Docker/Rails/search stack” before we rely on agents in the contributor workflow

Do **not** put Harbor in the request path of [ebwiki.org](https://ebwiki.org), and do **not** give agents production database dumps.

## What Harbor is

Harbor (from the Terminal-Bench authors) runs **any agent + any model + any task + any sandbox** in parallel.

A task is a directory:

```text
my-task/
├── instruction.md      # what the agent must do
├── task.toml           # timeouts, image, resources
├── environment/        # Dockerfile and/or docker-compose.yaml
├── solution/           # oracle script that proves the task is solvable
└── tests/              # test.sh writes 0/1 (or richer scores) to /logs/verifier/
```

A **trial** is one agent attempt. A **job** is a batch of trials. Harbor can run locally on Docker or on cloud sandboxes (Modal, Daytona, and others).

Install (developer machine or CI runner, not the Rails process):

```bash
uv tool install harbor
# requires Docker for local trials
harbor run --path harbor/tasks --include-task-name smoke-rails-version --agent oracle --yes
```

`cursor-cli` is one of Harbor’s pre-integrated agents, so the same tasks can score Cursor as well as Claude Code or Codex.

## Why this maps onto EBWiki

EBWiki already has the pieces Harbor wants:

| EBWiki today | Harbor use |
| --- | --- |
| `Dockerfile` + `make build` / `make run` | Task `environment/` or `[environment].docker_image` |
| Published `ebwiki/ebwiki` image | Skip per-task image builds |
| `compose.yaml` (Postgres 17, Redis 7) | Sidecars in `environment/docker-compose.yaml` |
| CI: RSpec, Rubocop, Brakeman | Verifiers can *call* those tools; they do not replace them |
| `docs/DEVELOPMENT.md` contributor timeline | Task `instruction.md` for “good first issue” style work |
| Sensitive case data | Seed data only; never production dumps in an agent sandbox |

Harbor’s multi-container model matches our stack: the agent lives in a reserved Compose service named `main`; Postgres and Redis are sidecars on the same Docker network. Case search is `pg_search` on Postgres — do **not** add an Elasticsearch sidecar.

## What “attach” means (and does not)

Attach means a `harbor/` tree in this repo (or a sibling `EBWiki/harbor-tasks` repo) that Harbor can run with:

```bash
harbor run --repo EBWiki/EBWiki -p harbor/tasks -a oracle
harbor run --path harbor/tasks --agent claude-code --model anthropic/claude-sonnet-5 --yes
```

It does **not** mean:

- A Ruby gem in the Rails bundle
- Changing how humans run `make run` or `rails s`
- Replacing GitHub Actions CI
- Giving agents a bind-mount of a developer’s dirty working tree (Harbor snapshots an isolated environment per trial)

Human local development stays on [SETUP_LOCALLY.md](SETUP_LOCALLY.md). Harbor is for measuring and iterating on **agent** development against EBWiki.

## Proposed layout

```text
harbor/
  README.md
  registry.json                    # optional named datasets
  jobs/                            # gitignored trial output
  environments/
    ebwiki-dev/
      Dockerfile                   # thin wrapper around the app image
      docker-compose.yaml          # postgres and redis sidecars (pg_search, no ES)
  tasks/
    smoke-rails-version/           # oracle + image only; no extra services
    fix-failing-spec/              # agent makes a red spec green
    add-model-annotation/          # typical contributor chore
    docker-contributor-setup/      # “follow SETUP_LOCALLY” as a scored task
```

Local humans use repo-root `compose.yaml`. Harbor copies the same sidecar versions into `harbor/environments/ebwiki-dev/`. Individual tasks can set `[environment].docker_image = "ebwiki/ebwiki:latest"` after `docker compose build`.

A starter smoke task lives at `harbor/tasks/smoke-rails-version/`.

Case search is Postgres `pg_search` (`Case.search_text` / `CaseSearch`). Searchkick and Elasticsearch are out of the stack — Harbor environments must not add an ES sidecar.

## First tasks (smallest useful set)

Start with tasks that are **oracle-solvable**, **offline-friendly**, and **do not need production data**.

1. **Smoke: Rails version** — `bundle exec rails -v` written to a file. Proves image pull, Harbor install, and verifier wiring. No database.
2. **Boot check** — `rails runner 'puts Rails.application.class.name'` against Compose Postgres. Proves sidecars and `database.yml` for agents.
3. **Make a spec pass** — check out a known-broken spec (or introduce one in `workdir/setup.sh`) and require the agent to fix it so `rspec` is green. This is the first *development* task.
4. **Contributor chore** — e.g. add an annotate comment after a tiny migration, matching [DEVELOPMENT.md](DEVELOPMENT.md).

Promote those four into a `registry.json` dataset named `ebwiki-dev` once the oracle agent scores `1` on all of them.

## Gaps we must close before this is useful

The app image is the Rails process only. Sidecars are Compose.

1. **App image vs sidecars.** The root `Dockerfile` is the Rails app only. Postgres 17 and Redis 7 live in repo `compose.yaml` (and the Harbor copies under `harbor/environments/ebwiki-dev/`). Do not start `service postgresql` inside `main`.
2. **Test gems.** The image installs development + test gems (`BUNDLE_WITHOUT=production`). Harbor RSpec tasks reuse `ebwiki/ebwiki:latest`; they do not re-bundle.
3. **Published image CMD is the Rails server.** Harbor overrides `main` to `sleep infinity`. Compose healthchecks wait on Postgres/Redis, not on port 3000, unless the task is “the site is up.”
4. **CI image vs local image.** GitHub Actions uses host Ruby + service containers (`postgres:17`, Redis). Harbor tasks pin the same service versions. Search uses `pg_search`; do not add Elasticsearch.
5. **Secrets.** Agent trials need model API keys on the *host* (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, …). Those must never be baked into `task.toml` or the image. Use Harbor’s `${VAR}` env templates and gitignore `jobs/` (Harbor writes that directory in the current working directory).
6. **Data sensitivity.** `docs/DEVELOPMENT.md` allows restoring a production backup for analytics work. That path is out of scope for Harbor. Agents get `db/seeds.rb` only.

## Suggested first increment (after this spike)

In-tree now: repo-root `compose.yaml` + modern app `Dockerfile`, smoke task, Harbor sidecars, `boot-rails`, `fix-failing-spec`, `harbor/registry.json` (`ebwiki-dev`), and a GitHub Actions job that **lints** Harbor task layout (no paid models, no `harbor run`).

Still local (Docker required):

1. `harbor run --path harbor/tasks --include-task-name smoke-rails-version --agent oracle --yes`
2. `harbor run --path harbor/tasks --include-task-name boot-rails --agent oracle --yes`
3. `harbor run --path harbor/tasks --include-task-name fix-failing-spec --agent oracle --yes`

Only then try a paid agent (`-a claude-code` or `-a cursor-cli`) on the spec-fix task.

## Cost, ops, and risk

- **Local:** Docker CPU/RAM. A Rails + Postgres + Redis trial is lighter than the old ES stack; budget ~2–4 GB RAM per concurrent trial.
- **Cloud sandboxes:** faster parallelism; check which providers support Compose (Docker/Podman yes; several hosted providers use DinD; some do not support Compose at all).
- **Paid agents:** each trial spends model tokens. Start with `-a oracle` and one cheap model on the smoke task.
- **Network:** default Harbor network is public. Prefer `network_mode = "allowlist"` plus rubygems/GitHub hosts so agents cannot wander. Harbor 2026 builds an egress sidecar with `docker buildx`; install the Buildx plugin (`docker-buildx` on Ubuntu).
- **License:** Harbor is Apache 2.0, same family as EBWiki.

## Decision

| Option | When to pick it |
| --- | --- |
| **A. Attach Harbor (recommended)** | We want a scored, reproducible way to develop *with* coding agents on EBWiki |
| B. Wait | We only need human Docker/RSpec workflows; skip until someone owns agent eval |
| C. External repo | Tasks should not live in the public app repo (e.g. they include unpublished issues) |

This spike assumes **A**, with tasks in-tree under `harbor/` so they version with the app they evaluate.

## References

- Harbor repo: https://github.com/harbor-framework/harbor
- Harbor docs: https://docs.harborframework.com/
- Create a task: https://docs.harborframework.com/tutorials/create-a-task
- Multi-container / Compose: https://docs.harborframework.com/core-concepts/tasks/multi-container
- Pre-integrated agents (includes `cursor-cli`): https://docs.harborframework.com/core-concepts/agents/pre-integrated-agents
- EBWiki Docker setup: [SETUP_LOCALLY.md](SETUP_LOCALLY.md)
- EBWiki contributor flow: [DEVELOPMENT.md](DEVELOPMENT.md)
