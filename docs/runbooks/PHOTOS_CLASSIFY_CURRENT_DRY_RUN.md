# Runbook: dry-run `photos:classify_current`

Stack: friendly photos (#4450) — `FriendlyPhotos::CurrentAvatarClassifier` /
`photos:classify_current`. Parent tracking: Linear **GKT-175** (mugshots kept;
this task only sets `avatar_kind: mugshot` on filename hits — it does not strip
avatars).

**Never run with `APPLY=1` on production** unless an operator explicitly
approves a backfill. This runbook is for counting first.

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

### 3. Review / staging checklist

1. Run dry-run rake (or runner) against the target database.
2. Record `would_mark_mugshot` and `unchanged` in the ticket.
3. Spot-check a few `would_mark_mugshot` cases in the app (Profile pictures /
   case edit) before any `APPLY=1` run.
4. Do **not** merge this runbook PR into an automated production backfill.

## Related docs

- [`docs/FRIENDLY_PHOTOS.md`](../FRIENDLY_PHOTOS.md) — product workflow and agent routine.
