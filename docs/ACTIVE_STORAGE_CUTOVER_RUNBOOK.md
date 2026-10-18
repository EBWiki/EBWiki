# Active Storage cutover runbook (Case photos)

Operational steps for the CarrierWave to Active Storage photo migration. Each production step needs an explicit **Mark GO** before it runs.

## Stack order (code)

1. Slice 1: Active Storage tables and dual-mount config (PR #4490).
2. Slice 2: Backfill task and service (PR #4496, #4501).
3. Slice 4a: Read path prefers Active Storage (PR #4504).
4. Slice 5a: App stops using legacy `cases.avatar` columns (writes use Active Storage `photo`; this PR).
5. Slice 5b: Drop legacy `cases.avatar` columns (guarded migration in this PR).

Deploy slice 5a app code before running the slice 5b column drop. The drop migration must not run while `Case` still mounts CarrierWave on `avatar` or reads those columns in helpers or controllers.

## Before slice 5b (column drop), required

1. Confirm backfill completed successfully on that environment (`bin/rails active_storage:backfill_case_photos`; exit code 0, no unresolved `missing_file` unless explicitly accepted). Backfill only copies cases with a non-blank `avatar` column; it does not fix rows that only have `default_avatar_url` set.
2. **Take a full database backup** (for example `pg_dump -Fc` of the application database) and confirm the backup artifact is restorable. Slice 5b is **CRITICAL**: rolling back the migration only recreates empty avatar columns; restoring avatar *values* requires restore from this backup.
   - **Production backup location:** Railway Postgres manual backup named `pre-avatar-drop-YYYY-MM-DD` on the production database service, plus a `pg_dump --format=custom` file stored outside the app container (for example Mark's local workstation or team S3 bucket `ebwiki-db-backups`).
3. Run the safety check (same rule as the migration guard):

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

   The count must be **0** before `bin/rails db:migrate` reaches `RemoveCarrierwaveAvatarColumnsFromCases`. If the migration runs with `ALLOW_CASE_AVATAR_COLUMN_DROP=1`, it applies the same check and aborts with the case count when unsafe.

4. **Fix rows with only `default_avatar_url` set** (backfill cannot attach a photo for them):

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

   For each row, either attach a `photo` through the app (after slice 5a is deployed), upload a file and attach via console, or clear the stale URL with `UPDATE cases SET default_avatar_url = NULL WHERE id = ?` when the URL is obsolete. Re-run step 3 until the count is 0.

5. Confirm slice 5a app code is deployed (no `mount_uploader :avatar`, case forms use `photo`, `Case.ignored_columns` includes the three legacy columns).

6. **Mark GO** for slice 5b only after steps 1 through 5 pass.

## Slice 5b migrate

```bash
export ALLOW_CASE_AVATAR_COLUMN_DROP=1
bin/rails db:migrate
```

Run only in staging/production (or local rehearsal) after **Mark GO**. Without `ALLOW_CASE_AVATAR_COLUMN_DROP=1`, the migration **raises** and the deploy fails; Rails does **not** record the migration version. That is intentional so a later maintenance-window migrate can still run the drop.

Set the variable on the Railway service (or export it for the one-off migrate) only for the maintenance-window run. Railway release tasks call `bin/rails db:migrate` on every deploy, so a normal deploy before GO will fail at this migration until the window.

If the guard raises, do not force the migration. Fix backfill gaps, default_avatar_url-only rows, or storage, re-run step 2 (fresh backup), then retry.

## Rollback notes

- `bin/rails db:rollback` for slice 5b re-adds `avatar`, `default_avatar_url`, and `remove_avatar` columns **without** repopulating legacy values.
- To recover dropped avatar data, restore the pre-5b backup (for example `pg_restore` into a staging copy first).
- **Code rollback:** revert the merge commit on main, redeploy the previous Railway deployment (or the previous release tag), do not only run `git revert` locally without redeploying.
- **Tag at merge:** `v2026.10.18-N` (N is the next free number that day). **Previous tag for redeploy:** the latest `v*` tag on main at merge time.
