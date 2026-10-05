# Runbook: dry-run `photos:classify_current`

Stack: friendly photos (#4450) — `FriendlyPhotos::CurrentAvatarClassifier` /
`photos:classify_current`. Parent tracking: Linear **GKT-175** (mugshots kept;
this task only sets `avatar_kind: mugshot` on filename hits — it does not strip
avatars).

**No production `APPLY=1` without operator GO.** Dry-run is the default;
writes are opt-in. This runbook is for counting and staging review first.

Parent Linear **GKT-175** stays open (mugshots kept; classify only tags
filename hits — it does not strip avatars). Child **GKT-696** tracks this
checklist on stack PR [#4462](https://github.com/EBWiki/EBWiki/pull/4462).

## What it does

For each case with a stored avatar filename:

- **Would mark as mugshot** — `avatar_kind` is still unclassified and
  `MugshotClassifier` treats the filename as a booking/mugshot path.
- **Unchanged** — no write on this run (already classified, or filename not
  mugshot-like, or blank avatar skipped entirely).

Dry-run performs the same scan with **no** `UPDATE` statements.

## Commands

### 1. Rake (default dry-run)

```bash
bundle exec rake photos:classify_current
```

Persist only when intentional:

```bash
bundle exec rake photos:classify_current APPLY=1
```

### 2. Rails runner (same logic, JSON counts)

Useful in CI logs or when rake task output must be machine-parsed:

```bash
bundle exec rails runner 'p FriendlyPhotos::CurrentAvatarClassifier.call(dry_run: true)'
```

Expected shape:

```ruby
{ would_mark_mugshot: <Integer>, unchanged: <Integer> }
```

### 3. Dry-run review (staging / review DB)

Complete before any `APPLY=1`:

1. Run dry-run rake (or runner) against the **same** database you would write to.
2. Record `would_mark_mugshot` and `unchanged` in the Linear ticket.
3. Spot-check several `would_mark_mugshot` cases in the app (Profile pictures /
   case edit): confirm filenames look like booking/mugshot paths, not family
   portraits mis-tagged by the heuristic.

### 4. `APPLY=1` safety checklist (required)

Use this checklist for **every** non-local `APPLY=1` run. If any item is
unchecked, stop — stay on dry-run.

| Step | Check |
| --- | --- |
| Environment | Target is **review/staging**, or production only after explicit **GO** from a human operator documented in Linear (not implied by merging a docs PR). |
| Dry-run parity | Dry-run already ran on this **same** database; counts are recorded in the ticket. |
| Scope | You intend only to set `avatar_kind: mugshot` on filename hits — **no** avatar removal, **no** friendly-photo search/apply. |
| Spot-check | At least a few `would_mark_mugshot` cases were opened in the app and look correct. |
| Authorization | For production: written **GO** in GKT-175 (or linked child) naming who approved and when. Without GO, **do not** run `APPLY=1` on production. |
| Command | You are running `bundle exec rake photos:classify_current APPLY=1` intentionally (not a copy-paste from docs into prod shell). |
| After run | Re-run dry-run or spot-check updated cases; note final counts in the ticket. |

**Never:** merge [#4462](https://github.com/EBWiki/EBWiki/pull/4462) or this
checklist into an automated production backfill, CI job, or release task without
the same GO and checklist.

### 5. Production gate (no prod without GO)

- **Default:** dry-run only (`APPLY` unset or `APPLY=0`).
- **Review/staging:** `APPLY=1` is allowed after section 4 checklist on that DB.
- **Production:** `APPLY=1` is **forbidden** until a human operator posts **GO**
  in Linear (parent GKT-175 or the active child). Agents and CI must not run
  `APPLY=1` against production.
- **Deploy:** shipping the runbook or rake task does **not** authorize a prod
  backfill. GO is a separate human decision.

## Related docs

- [`docs/FRIENDLY_PHOTOS.md`](../FRIENDLY_PHOTOS.md) — product workflow and agent routine.
