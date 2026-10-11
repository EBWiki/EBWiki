# Staging cutover: migrations vs image `ebwiki/ebwiki:184`

Before OpenTofu apply, **`scripts/staging-db-snapshot.sh`** streams **`pg_dump -Fc`** from **inside the Railway Postgres service** (`railway ssh` on **`Postgres`**, `postgres:17` with **`POSTGRES_*`** env). This works while the app still runs image **`ebwiki/ebwiki:184`** (no client tools there). The dump uploads to **`staging/db-snapshots/<timestamp>.dump`** on the bootstrap R2 bucket (credentials in Doppler **`ebwiki/infra`**). Nothing is written under **`/tmp`** on the operator machine. **`scripts/staging-apply.sh`** runs the snapshot script before **`tofu apply`**.

After snapshot, confirm the stream is a valid archive (lists tables):

```bash
doppler run --project ebwiki --config infra -- sh -ec '
  key="staging/db-snapshots/<timestamp>.dump"
  aws s3 cp "s3://${R2_BUCKET_NAME}/${key}" - --endpoint-url "${R2_S3_ENDPOINT}" | pg_restore --list | head
'
```

If **`pg_restore --list`** fails or shows no tables, do not apply. Fix the snapshot path (or switch to Railway volume backups) before cutover.

Image **`ebwiki/ebwiki:184`** and **`main`** both ship the same **56** files under **`db/migrate`**, including **`20260428164616_remove_case_foreign_key_from_polymorphic_links`** and **`20260428201731_add_tsv_to_cases`**. The cutover runs **no new migrations**; **`release-tasks.sh`** should report nothing pending at deploy time.

**Rollback:** Do **not** run **`db:rollback`** as part of this rollback. Rolling back migrations would undo schema that image 184 already expects. If a migrate step fails anyway, restore the R2 snapshot, then redeploy the previous Railway image or commit as needed.

## Restore from R2 (inside Railway)

List snapshots:

```bash
doppler run --project ebwiki --config infra -- \
  aws s3 ls "s3://${R2_BUCKET_NAME}/staging/db-snapshots/" --endpoint-url "${R2_S3_ENDPOINT}"
```

Restore (destructive; use only when rolling back a failed migrate). Set **`CONFIRM_RESTORE`** to the Railway **project id** (printed by the script), and ensure the snapshot object exists:

```bash
doppler run --project ebwiki --config infra -- \
  env CONFIRM_RESTORE="<project-id>" ./scripts/staging-db-restore.sh staging/db-snapshots/<timestamp>.dump
```

Restore runs **`pg_restore --single-transaction --exit-on-error`** on the Postgres service and refuses unless **`POSTGRES_DB`** matches **`STAGING_EXPECTED_POSTGRES_DB`** (default **`railway`**).

After restore, redeploy image **`ebwiki/ebwiki:184`** if needed.
