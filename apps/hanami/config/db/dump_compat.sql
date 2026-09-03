-- Adapt a 2020-era latest.dump so Hanami can read it.
-- Safe to re-run. Do not point this at a shared Rails production database.

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
