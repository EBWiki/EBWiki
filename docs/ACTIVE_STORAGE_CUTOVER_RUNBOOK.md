# Active Storage cutover runbook (Case photos)

Operational steps for the CarrierWave to Active Storage photo migration. Each production step needs an explicit **Mark GO** before it runs.

## Stack order (code)

1. Slice 1: Active Storage tables and dual-mount config (PR #4490).
2. Slice 2: Backfill task and service (PR #4496, #4501).
3. Slice 4a: Read path prefers Active Storage (PR #4504).
4. Slice 5a: App stops using legacy `cases.avatar` columns (writes use Active Storage `photo`; ships in its own PR).
5. Slice 5b: Drop legacy `cases.avatar` columns (guarded migration in a **separate PR**, merged only at the maintenance window after Mark GO).

Deploy slice 5a before merging slice 5b. Slice 5b must not be on the deploy branch until the window, so Railway pre-deploy `db:migrate` is not blocked during normal releases.

## Before slice 5a deploy, required

1. Run backfill on that environment: `bin/rails active_storage:backfill_case_photos` (exit code 0; no unresolved `missing_file` unless explicitly accepted). Backfill only copies cases with a non-blank `avatar` column; it does not fix rows that only have `default_avatar_url` set.
2. Run the read-only safety count (same rule as the column-drop guard):

   ```bash
   bin/rails active_storage:case_avatar_drop_check
   ```

   Or run the equivalent SQL from the slice 5b section below. The count must be **0** before deploying slice 5a. After slice 5a, the helper no longer falls back to CarrierWave avatars, so any case with legacy data but no `photo` shows the default icon.

3. **Fix rows with only `default_avatar_url` set** (backfill cannot attach a photo for them):

   ```sql
   SELECT id, default_avatar_url
   FROM cases
   WHERE NULLIF(BTRIM(avatar::text), '') IS NULL
     AND NULLIF(BTRIM(default_avatar_url::text), '') IS NOT NULL
     AND NOT EXISTS (
       SELECT 1 FROM active_storage_attachments a
       WHERE a.record_type = 'Case'
         AND a.record_id = cases.id
         AND a.name = 'photo'
     );
   ```

   For each row, attach a `photo` through the app, attach via console, or clear the stale URL with `UPDATE cases SET default_avatar_url = NULL WHERE id = ?` when the URL is obsolete. Re-run the count task until it exits 0.

4. **Mark GO** for slice 5a deploy only after steps 1 through 3 pass.

## Before slice 5b (column drop), required

1. Confirm slice 5a is deployed on that environment (case forms use `photo`, `Case.ignored_columns` includes the three legacy columns).
2. Re-run backfill and `bin/rails active_storage:case_avatar_drop_check` (count must be 0).
3. **Take a full database backup** (for example `pg_dump -Fc` of the application database) and confirm the backup artifact is restorable. Slice 5b is **CRITICAL**: rolling back the migration only recreates empty avatar columns; restoring avatar *values* requires restore from this backup.
   - **Production backup location:** Railway Postgres manual backup named `pre-avatar-drop-YYYY-MM-DD`, plus a `pg_dump --format=custom` file in the team S3 bucket `ebwiki-db-backups`.
4. Run the safety check SQL (same as the guard):

   ```sql
   SELECT COUNT(*)
   FROM cases c
   WHERE NOT EXISTS (
       SELECT 1 FROM active_storage_attachments a
       WHERE a.record_type = 'Case'
         AND a.record_id = c.id
         AND a.name = 'photo'
     )
     AND (
       NULLIF(BTRIM(c.avatar::text), '') IS NOT NULL
       OR NULLIF(BTRIM(c.default_avatar_url::text), '') IS NOT NULL
       OR (
         c.remove_avatar IS TRUE
         AND (
           NULLIF(BTRIM(c.avatar::text), '') IS NOT NULL
           OR NULLIF(BTRIM(c.default_avatar_url::text), '') IS NOT NULL
         )
       )
     );
   ```

5. **Mark GO** for slice 5b merge and migrate only after steps 1 through 4 pass.

## Slice 5b migrate (slice 5b PR only, at the window)

```bash
export ALLOW_CASE_AVATAR_COLUMN_DROP=1
bin/rails db:migrate
```

Merge the slice 5b PR at the maintenance window, set `ALLOW_CASE_AVATAR_COLUMN_DROP=1` on Railway for that deploy, and confirm release migrate succeeds. Until that PR merges, the drop migration is not on the deploy branch and cannot block releases.

If the guard raises, do not force the migration. Fix backfill gaps, default_avatar_url-only rows, or storage, re-run step 3 (fresh backup), then retry.

## Rollback notes

- `bin/rails db:rollback` for slice 5b re-adds `avatar`, `default_avatar_url`, and `remove_avatar` columns **without** repopulating legacy values.
- To recover dropped avatar data, restore the pre-5b backup (for example `pg_restore` into a staging copy first).
- **Code rollback:** revert the merge commit on main, then redeploy the previous Railway release (or the previous release tag), not only `git revert` locally without redeploying.
- **Tag at slice 5b merge:** `v2026.10.18-N` (N is the next free number that day). **Redeploy rollback target:** latest `v*` tag on main immediately before that merge.
