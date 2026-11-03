# Scrubbed ebwiki-review database (photo search slice 1)

Linear: [GKT-1408](https://linear.app/gkt/issue/GKT-1408).

This slice prepares a **Neon branch** of project `ebwiki-review` (2020 archive copy) with **no real EBWiki user personal data**, then points **staging** at that branch so photo search work can use real case content safely.

Production and the source Neon project are **read-only** for operators: create a **new branch**, scrub on the branch connection string, load staging from the branch only.

## Doppler secret names (values never in git)

| Name | Used by | Purpose |
| --- | --- | --- |
| `EBWIKI_REVIEW_DATABASE_URL` | Scrub and assert scripts | Postgres URL for the **scrubbed Neon branch** (create branch in Neon UI or API; paste URL into Doppler only). |
| `DATABASE_URL` | Staging Rails and `staging-case-load-report.sh` | Staging Postgres after it points at the scrubbed branch (`ebwiki/stg`). |

Neon API or console credentials for creating the branch live in Doppler under the name your infra runbook uses (for example a Neon API key in `ebwiki/infra`). This repository does not add new Doppler keys until infra PRs land; operators set `EBWIKI_REVIEW_DATABASE_URL` on the scrubbed branch when the branch exists.

## Operator flow

1. Create a Neon **branch** from `ebwiki-review` (do not write to the parent branch).
2. Put the branch connection string in Doppler as `EBWIKI_REVIEW_DATABASE_URL`.
3. Run scrub, then assert (paste both command outputs into the Linear ticket for verification):

```bash
doppler run --project ebwiki --config infra -- \
  ./scripts/photo-search/scrub-ebwiki-review.sh

doppler run --project ebwiki --config infra -- \
  ./scripts/photo-search/assert-ebwiki-review-scrubbed.sh
```

4. Load the scrubbed branch into staging Postgres (pg_restore or Neon branch swap). Set staging `DATABASE_URL` in Doppler `ebwiki/stg` to the scrubbed branch.
5. Confirm staging sees **4,033 cases**:

```bash
doppler run --project ebwiki --config stg -- \
  ./scripts/photo-search/staging-case-load-report.sh
```

## What the scrub changes

**Scrubbed (contributor / session PII)**

| Table | Columns or rows |
| --- | --- |
| `users` | `email`, `name`, `encrypted_password`, `reset_password_token`, `confirmation_token`, sign-in timestamps and IPs, `facebook_url`, `twitter_url`, `linkedin`, `description`, `city`, `storytime_name`, `latitude`, `longitude`, `state` |
| `sessions` | all rows deleted |
| `versions` | `whodunnit`, `ip` cleared |
| `visits`, `ahoy_events` | all rows deleted |
| `mailboxer_*` | all rows deleted |

**Left unchanged (published archive content)**

Case tables and related editorial data: victim names in `cases` / `subjects`, dates, places, agencies, sources, case bodies, comments on cases, agency contact fields on `agencies`, and similar published fields.

Implementation: `lib/photo_search/review_database_scrub.rb`.

## Assertion checks

The assert script must print **0** for every check:

| Check | SQL idea |
| --- | --- |
| Real emails | `users.email NOT LIKE '%@example.invalid'` |
| Reset tokens | `reset_password_token IS NOT NULL` |
| Confirmation tokens | `confirmation_token IS NOT NULL` |
| Password digests | any `encrypted_password` not equal to the scrub sentinel |
| User IPs | `current_sign_in_ip` or `last_sign_in_ip` set |
| Version attribution IPs | `versions.whodunnit` or `versions.ip` set |
| Visit IPs | `visits.ip` set |
| Sessions | any row in `sessions` |

Implementation: `lib/photo_search/review_database_assertions.rb`.

## Staging case loader

`PhotoSearch::StagingCaseLoader` reads rows from `cases` for downstream photo search jobs. It does not copy data; it verifies count and yields case metadata from the connected database.

## Rollback

Point staging `DATABASE_URL` back at the previous database URL in Doppler. Delete the Neon branch only with explicit approval (branch delete is destructive).
