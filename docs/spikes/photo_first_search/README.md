# Photo-first search spike: pgvector k-NN

This spike proves the **database shape and query pattern** for photo similarity search. It does **not** download SigLIP or CLIP weights. Synthetic vectors stand in for real embeddings until the embedding container lands (see [PHOTO_FIRST_SEARCH_PLAN.md](../../PHOTO_FIRST_SEARCH_PLAN.md)).

## Prerequisites

- Postgres 15+ with the **pgvector** extension (Neon supports this on project branches).
- `DATABASE_URL` using a **direct** connection for DDL (not the pooler), when creating extensions.

## Files

| File | Purpose |
| --- | --- |
| `001_pgvector_schema.sql` | Extension, tables, HNSW index |
| `synthetic_neighbor_demo.rb` | Inserts three synthetic 768-d vectors and runs k-NN |

## Run the demo

```bash
export DATABASE_URL='postgresql://user:pass@host/dbname'
ruby docs/spikes/photo_first_search/synthetic_neighbor_demo.rb
```

Dry run (prints SQL only, no database):

```bash
DRY_RUN=1 ruby docs/spikes/photo_first_search/synthetic_neighbor_demo.rb
```

Expected output includes the nearest neighbor `case_id` to a probe vector (deterministic because vectors are fixed in the script).

## Cleanup

The demo uses tables prefixed with `photo_search_spike_` and drops them at the end. If the script aborts mid-run:

```sql
DROP TABLE IF EXISTS photo_search_spike_embeddings;
```
