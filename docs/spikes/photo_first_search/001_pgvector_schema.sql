-- Planned production-shaped DDL for photo-first search (not applied by this planning PR).
-- Requires Postgres with pgvector. Run on a direct Neon connection for CREATE EXTENSION.

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS case_photo_embeddings (
  id bigserial PRIMARY KEY,
  case_id bigint NOT NULL,
  photo_sha256 char(64) NOT NULL,
  source_url text,
  model_id text NOT NULL DEFAULT 'google/siglip2-base-patch16-256',
  embedding vector(768) NOT NULL,
  indexed_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (case_id, photo_sha256, model_id)
);

CREATE INDEX IF NOT EXISTS index_case_photo_embeddings_on_case_id
  ON case_photo_embeddings (case_id);

CREATE INDEX IF NOT EXISTS index_case_photo_embeddings_hnsw_cosine
  ON case_photo_embeddings
  USING hnsw (embedding vector_cosine_ops);

CREATE TABLE IF NOT EXISTS case_photo_provenance (
  id bigserial PRIMARY KEY,
  case_id bigint NOT NULL,
  photo_sha256 char(64) NOT NULL,
  attribution_text text NOT NULL,
  license_notes text,
  takedown_at timestamptz,
  UNIQUE (case_id, photo_sha256)
);
