# Active Storage cutover runbook (Case photos)

Operational steps for the CarrierWave → Active Storage photo migration. Each production step needs an explicit **Mark GO** before it runs.

## Stack order (code)

1. Slice 1 — Active Storage tables and dual-mount config (PR #4490).
2. Slice 2 — Backfill task and service (PR #4496, #4501).
3. Slice 4a — Read path prefers Active Storage with CarrierWave fallback (PR #4504).
4. Slice 5a — Writes go to Active Storage `photo` (separate PR; not on main yet).
5. Slice 5b — Drop legacy `cases.avatar` columns (guarded migration).

## Before slice 5b (column drop) — required

1. Confirm backfill completed successfully on that environment (`bin/rails active_storage:backfill_case_photos`; exit code 0, no unresolved `missing_file` unless explicitly accepted).
2. **Take a full database backup** (for example `pg_dump -Fc` of the application database) and confirm the backup artifact is restorable. Slice 5b is **CRITICAL**: rolling back the migration only recreates empty avatar columns; restoring avatar *values* requires restore from this backup.
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

   The count must be **0** before `bin/rails db:migrate` reaches `RemoveCarrierwaveAvatarColumnsFromCases`. If the migration runs, it applies the same check and aborts with the case count when unsafe.

4. **Mark GO** for slice 5b only after steps 1–3 pass.

## Slice 5b migrate

```bash
bin/rails db:migrate
```

Run only in staging/production (or local rehearsal) after **Mark GO**. The migration always runs the safety guard. Column drops are skipped unless `ALLOW_CASE_AVATAR_COLUMN_DROP=1` is set (so Railway’s automatic release migrate cannot drop columns by accident). In the `test` Rails env, set `EBWIKI_RUN_SLICE_5B_COLUMN_DROP=1` in specs to exercise the real drop path.

If the guard raises, do not force the migration. Fix backfill gaps or storage, re-run step 2 (fresh backup), then retry.

## Rollback notes

- `bin/rails db:rollback` for slice 5b re-adds `avatar`, `default_avatar_url`, and `remove_avatar` columns **without** repopulating legacy values.
- To recover dropped avatar data, restore the pre-5b backup (for example `pg_restore` into a staging copy first).
