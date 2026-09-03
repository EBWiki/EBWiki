-- Expand the 2020 cause_of_death enum to the current Rails/Hanami values.
-- Run outside a test transaction (PostgreSQL restriction on ADD VALUE).

ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'choking';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'shooting';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'beating';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'taser';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'vehicular';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'medical neglect';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'response to medical emergency';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'suicide';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'chemical_agents_or_weapons';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'drowning';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'stabbing';
ALTER TYPE public.cause_of_death ADD VALUE IF NOT EXISTS 'bombing';
