-- Ensure sessions table exists for review apps restored from historic dumps.
-- Historic latest.dump omits this table while schema_migrations may already
-- record 20181005060647_add_sessions_table, so db:migrate will not recreate it.
-- Safe to re-run (matches db/migrate/20181005060647_add_sessions_table.rb).

CREATE TABLE IF NOT EXISTS public.sessions (
    id serial PRIMARY KEY,
    session_id character varying NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE UNIQUE INDEX IF NOT EXISTS index_sessions_on_session_id
  ON public.sessions USING btree (session_id);

CREATE INDEX IF NOT EXISTS index_sessions_on_updated_at
  ON public.sessions USING btree (updated_at);
