-- Scrub personal data after copying production data onto staging.
-- Run by script/refresh_staging_from_production against the STAGING database only.
-- Public case data (cases, subjects, agencies, links, public comments) is left as is.
\set ON_ERROR_STOP on
BEGIN;

-- Accounts: fake addresses, unusable random passwords, no tokens, IPs or home locations.
CREATE SCHEMA scrub_tmp;
CREATE EXTENSION pgcrypto WITH SCHEMA scrub_tmp;
UPDATE users SET
  email = 'user' || id || '@example.invalid',
  encrypted_password = scrub_tmp.crypt(gen_random_uuid()::text, scrub_tmp.gen_salt('bf', 4)),
  reset_password_token = NULL,
  reset_password_sent_at = NULL,
  remember_created_at = NULL,
  confirmation_token = NULL,
  current_sign_in_ip = NULL,
  last_sign_in_ip = NULL,
  latitude = NULL,
  longitude = NULL;
DROP SCHEMA scrub_tmp CASCADE;

-- Edit history: no IPs, no copies of user records, no email addresses.
UPDATE versions SET ip = NULL WHERE ip IS NOT NULL;
UPDATE versions SET object = NULL, object_changes = NULL WHERE item_type = 'User';
UPDATE versions
   SET object = regexp_replace(object, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', 'redacted@example.invalid', 'g')
 WHERE object ~* '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}';
UPDATE versions
   SET object_changes = regexp_replace(object_changes, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', 'redacted@example.invalid', 'g')
 WHERE object_changes ~* '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}';

-- Private messages between users, sessions, visits and analytics events.
TRUNCATE mailboxer_receipts, mailboxer_notifications, mailboxer_conversation_opt_outs, mailboxer_conversations;
TRUNCATE sessions, visits, ahoy_events;

-- Mark the copy as staging so Rails' protected-environment check applies to it.
UPDATE ar_internal_metadata SET value = 'staging' WHERE key = 'environment';

COMMIT;

-- Restore the monitoring extension the staging server preloads.
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
ANALYZE;
