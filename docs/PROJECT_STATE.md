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
Rails 8.1 modernization complete: pg_search, Active Storage, Trix, custom mailbox, Propshaft + Bootstrap 5 + Stimulus. Remaining Bootstrap 3 / jQuery / mailboxer leftovers removed.

## Technical Notes
- Case search uses `pg_search` over generated `cases.tsv`
- Uploads use Active Storage (`Case#photo`)
- Messaging uses `Conversation` / `Message` / `ConversationParticipant`
- Frontend: Propshaft, importmap, Turbo, Stimulus, dartsass, Bootstrap 5
