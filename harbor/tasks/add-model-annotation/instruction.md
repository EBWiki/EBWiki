# Add schema annotations after a Harbor-only migration

EBWiki is at `/usr/src/ebwiki` with Postgres 17 and Redis as sidecars.

A migration adds the `harbor_annotation_samples` table and `HarborAnnotationSample` exists in `app/models/`, but the model file is missing annotate-style schema comments (see [DEVELOPMENT.md](../../../docs/DEVELOPMENT.md)).

Run the migration if needed, then update the model so it includes a `# == Schema Information` block for `harbor_annotation_samples`.

Use seed data only. Do not restore a production dump.
