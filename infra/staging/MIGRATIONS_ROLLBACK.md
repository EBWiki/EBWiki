# Staging cutover: migrations vs image `ebwiki/ebwiki:184`

Before **`make apply`**, **`make snapshot`** dumps the Railway staging Postgres database with **`pg_dump`**, uploads **`staging/db-snapshots/<timestamp>.dump`** to the bootstrap R2 bucket (same credentials as OpenTofu state in Doppler **`ebwiki/infra`**). **`make apply`** runs **`make snapshot`** automatically.

Image **`ebwiki/ebwiki:184`** and **`main`** both ship the same **56** files under **`db/migrate`**, including **`20260428164616_remove_case_foreign_key_from_polymorphic_links`** and **`20260428201731_add_tsv_to_cases`**. The cutover runs **no new migrations**; **`release-tasks.sh`** should report nothing pending at deploy time.

**Rollback:** Do **not** run **`db:rollback`** as part of this rollback. Rolling back migrations would undo schema that image 184 already expects. If a migrate step fails anyway, **restore the snapshot** taken before apply, then redeploy the previous Railway image or commit as needed.
