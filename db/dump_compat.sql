-- Adapt a 2020-era latest.dump for EBWiki review (Rails + Hanami).
-- Safe to re-run. Do not point this at Heroku production.

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'cases' AND column_name = 'cause_of_death_name'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'cases' AND column_name = 'cause_of_death'
  ) THEN
    ALTER TABLE public.cases RENAME COLUMN cause_of_death_name TO cause_of_death;
  END IF;
END $$;

ALTER TABLE public.cases
  ADD COLUMN IF NOT EXISTS tsv tsvector
  GENERATED ALWAYS AS (
    to_tsvector(
      'english'::regconfig,
      (
        (COALESCE(title, ''::character varying))::text || ' ' ||
        COALESCE(blurb, ''::text) || ' ' ||
        COALESCE(overview, ''::text) || ' ' ||
        (COALESCE(city, ''::character varying))::text || ' ' ||
        COALESCE(summary, ''::text)
      )
    )
  ) STORED;

CREATE INDEX IF NOT EXISTS index_cases_on_tsv ON public.cases USING gin (tsv);

DO $$
DECLARE
  tbl text;
BEGIN
  FOREACH tbl IN ARRAY ARRAY[
    'cases', 'subjects', 'states', 'case_agencies', 'agencies',
    'users', 'comments', 'follows', 'links', 'organizations', 'versions'
  ]
  LOOP
    IF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public' AND tables.table_name = tbl
    ) THEN
      EXECUTE format(
        'DELETE FROM public.%I a USING public.%I b WHERE a.id = b.id AND a.ctid < b.ctid',
        tbl, tbl
      );
    END IF;

    IF EXISTS (
      SELECT 1 FROM information_schema.tables
      WHERE table_schema = 'public' AND tables.table_name = tbl
    ) AND NOT EXISTS (
      SELECT 1 FROM information_schema.table_constraints
      WHERE table_schema = 'public'
        AND table_constraints.table_name = tbl
        AND constraint_type = 'PRIMARY KEY'
    ) THEN
      EXECUTE format('ALTER TABLE public.%I ADD PRIMARY KEY (id)', tbl);
    END IF;
  END LOOP;
END $$;
