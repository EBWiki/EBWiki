# Staging cutover: migrations vs image `ebwiki/ebwiki:184`

Before OpenTofu apply, **`scripts/staging-db-snapshot.sh`** streams a **`pg_dump -Fc`** from **inside the deployed Railway app service** (`railway ssh` on the **ebwiki** service, using private network access to Postgres). The dump uploads to **`staging/db-snapshots/<timestamp>.dump`** on the bootstrap R2 bucket (credentials in Doppler **`ebwiki/infra`**). Nothing is written under **`/tmp`** on the operator machine. **`scripts/staging-apply.sh`** runs the snapshot script before **`tofu apply`**.

Image **`ebwiki/ebwiki:184`** and **`main`** both ship the same **56** files under **`db/migrate`**, including **`20260428164616_remove_case_foreign_key_from_polymorphic_links`** and **`20260428201731_add_tsv_to_cases`**. The cutover runs **no new migrations**; **`release-tasks.sh`** should report nothing pending at deploy time.

**Rollback:** Do **not** run **`db:rollback`** as part of this rollback. Rolling back migrations would undo schema that image 184 already expects. If a migrate step fails anyway, restore the R2 snapshot, then redeploy the previous Railway image or commit as needed.

## Restore from R2 (inside Railway)

List snapshots:

```bash
doppler run --project ebwiki --config infra -- \
  aws s3 ls "s3://${R2_BUCKET_NAME}/staging/db-snapshots/" --endpoint-url "${R2_S3_ENDPOINT}"
```

Restore (destructive; use only when rolling back a failed migrate):

```bash
doppler run --project ebwiki --config infra -- \
  ./scripts/staging-db-restore.sh staging/db-snapshots/<timestamp>.dump
```

After restore, redeploy image **`ebwiki/ebwiki:184`** if needed.
