# PROJECT STATE

_Snapshot as of 2026-08-15._

## Repo
- `EBWiki/EBWiki`

## Current Phase
- Rails 8.1 modernization

## Current Goal
Fully working Rails 8.1.3.1 app: pg_search, Active Storage, Action Text/Trix, custom mailbox, Propshaft + Bootstrap 5 + Stimulus.

## Current Branch
- cursor/rails-8-modernization-060d

## Last Completed Step
In-progress full modernization: dead gems removed, search on Postgres, frontend moved off Sprockets/jQuery.

## Technical Notes
- Case search uses `pg_search` over generated `cases.tsv`
- Uploads use Active Storage (`Case#photo`)
- Messaging uses `Conversation` / `Message` / `ConversationParticipant`
- Frontend: Propshaft, importmap, Turbo, Stimulus, dartsass, Bootstrap 5
