# Staging cutover: migrations vs image `ebwiki/ebwiki:184`

Before **`make apply`**, take a **Postgres snapshot** of the Railway staging database (operator action in Railway or provider console).

Image **`ebwiki/ebwiki:184`** predates these migrations on **`main`**. **`release-tasks.sh`** will run them on first deploy from source.

| Migration | Reversible | Rollback notes |
| --- | --- | --- |
| `20260428164616_remove_case_foreign_key_from_polymorphic_links.rb` | Yes | `bin/rails db:rollback` runs `down`, which re-adds the FK with `validate: false`. Safe if no orphan `links.linkable_id` values point at missing cases. |
| `20260428201731_add_tsv_to_cases.rb` | Yes | `down` drops GIN index and `cases.tsv` generated column. Image 184 does not use `tsv`; old code runs on schema without this column after rollback. |

If you roll the **service** back to image 184 **without** rolling migrations back, the database keeps the newer schema. Image 184 likely still boots because it ignores `tsv` and the removed FK only affects polymorphic link inserts.

**Recommended rollback order after a bad migrate:** restore DB snapshot, then redeploy image 184. Use `db:rollback STEP=2` only when snapshot restore is not available and you accept data risk.
