# Landing PRs

A landing pull request is **one named change** plus the **smallest unlock** that lets that change merge. Humans and agents use the same bar.

This is the rule that would have rejected a 73-file PR that mixed review-path cleanup (bot deletion, CODEOWNERS) with dozens of view and SCSS files.

This is the **ship** chapter of the full model in [Software development](SOFTWARE_DEVELOPMENT.md). The always-on agent rule is `.cursor/rules/landing-pr.mdc`. It adopts the reviewability line from Cursor team kit `make-pr-easy-to-review`: if a PR is too large to make reviewable with notes, split it instead of polishing around the problem. Compound Engineering and Superpowers stay installable as plugins; this repo vendors the model, not those kits.

## One concern

These are separate PRs unless the extra files are required to prove or ship the named change (for example a spec):

| Area | Examples |
|------|----------|
| Review path / hygiene | CODEOWNERS, bot config, CI workflow ownership |
| Application UI | `app/views`, SCSS, Stimulus |
| Library extract | New `lib/` objects pulled out of helpers |
| Dependencies | Bundler or npm bumps |
| Docs-only | Guides that do not unlock the named change |

## Size

If a reviewer cannot hold the diff in one pass, split it. Notes, commit squash, and a longer PR body do not make a mixed PR reviewable.

A landing PR that crosses about 25 files, or that mixes bot/CODEOWNERS deletion with application views, is already over the bar.

## Before you open the PR

1. Write the named change in one sentence.
2. Confirm every file is that change or its smallest unlock.
3. If not, split the branch. Open the smallest PR first.

If a working tree is already mixed, agents should use `.cursor/skills/splitting-oversized-prs/SKILL.md`.
