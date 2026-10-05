---
name: splitting-oversized-prs
description: Use when a branch, working tree, or draft PR mixes unrelated concerns, crosses a large file count, or is too large to review in one pass — including hygiene plus UI, library extract plus views, or a landing PR that is no longer one named change.
---

# Splitting Oversized PRs

## Overview

A landing PR is one named change plus the smallest unlock. If the diff is mixed or too large to review, split it. Do not polish, squash, or write reviewer notes to paper over the size.

## When to Use

- `git diff --stat origin/main` spans two or more areas (review-path, views/SCSS, lib extract, gems, unrelated docs)
- File count is high (about 25+) or a reviewer would need a guided tour
- The branch includes "while I am here" files that are not the unlock
- You are about to open or mark ready a PR that cannot be described in one sentence without "and"

## Procedure

1. Name the change in one sentence. Everything else is a candidate split.
2. Group files by area. Keep only the named change plus the smallest unlock on this branch.
3. Move other groups to new branches from the same base (`origin/main` unless a later PR truly depends on this one).
4. Open or update one PR per group. The first PR is the smallest unlock that can merge alone.
5. If the remaining tree is still too large to review, split again.

## Hard stops

- Do not hide a second concern inside "cleanup", "chore", or "also".
- Do not restyle UI to accompany a review-path change.
- Do not delete bots or CODEOWNERS in the same PR as `app/views` or SCSS.
- If `make-pr-easy-to-review` would say the PR is too large to make reviewable with notes, split.

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "It is all cleanup" | Cleanup of two systems is two PRs. |
| "Reviewers can skip the views" | Then the views are a second PR. |
| "Splitting loses context" | The PR body can link the follow-up. Mixed diffs lose review. |
| "I will explain it in the description" | Description does not make 70 files one concern. |
| "The unlock needed the restyle" | Unlock means the change cannot ship without it. Cosmetic SCSS can ship without CODEOWNERS. |

## Red flags

- PR title needs "and"
- Diff includes CODEOWNERS or bot config plus `app/views`
- You are reaching for `make-pr-easy-to-review` to annotate a mixed landing PR instead of splitting
