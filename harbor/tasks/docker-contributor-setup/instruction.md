# Contributor Docker setup (SETUP_LOCALLY)

This Harbor task scores whether an agent can complete the **contributor Docker setup** flow described in `docs/SETUP_LOCALLY.md`, adapted to this sandbox.

The environment is EBWiki at `/usr/src/ebwiki` with Postgres 17 and Redis as sidecars (same as local `compose.yaml`).

## Goal

1. Prepare the test database so Rails can boot against Compose Postgres.
2. Confirm the app toolchain with `bundle exec rails -v`.
3. Write proof to `/tmp/contributor_setup.txt`:
   - First line: the full output of `bundle exec rails -v` (must contain `Rails`).
   - Second line: exactly `ready`.

Use seed data only. Do not restore a production dump.

## Notes (stub)

Full parity with host `make run` / Docker Desktop is out of scope for this stub. The verifier only checks database prep, Rails version output, and the `ready` marker.
