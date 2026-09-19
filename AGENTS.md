# Agent instructions

EBWiki is a Rails 7 public archive. Durable team rules live here and in `.cursor/rules/`.

## Landing PRs

A landing PR is the named change plus the smallest unlock. One concern per PR.

- Review-path, bot, CODEOWNERS, and CI hygiene is not the same PR as view, SCSS, or UI work.
- Library extracts, dependency bumps, and unrelated docs are separate PRs.
- If the change set spans unrelated areas, split before opening or marking ready.
- If the PR is too large to review in one pass, split. Do not polish or annotate around the size.

Always-on Cursor rule: `.cursor/rules/landing-pr.mdc`. Human copy: `docs/LANDING_PRS.md`. If a branch is already mixed or oversized, use `.cursor/skills/splitting-oversized-prs/SKILL.md`.

Do not vendor Cursor plugin caches into this repository. Do not copy TypeScript-only rules. Do not run thermo-nuclear review on every commit.
