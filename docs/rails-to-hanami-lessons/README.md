# Rails to Hanami lessons from EBWiki

These lessons are built from the real EBWiki cutover, not a toy blog app.
Each one is a blog post, a 10–15 minute YouTube video, or a workshop module.

| Lesson | Hook | Rails start | Hanami finish |
| --- | --- | --- | --- |
| [01. Why we moved](01-why-we-moved.md) | A civic wiki outgrew its gem pile | `Gemfile`, Devise, PaperTrail, CarrierWave | `apps/hanami` on Railway |
| [02. Controllers become actions](02-controllers-become-actions.md) | The same URL, a thinner object | `CasesController#show` | `app/actions/cases/show.rb` |
| [03. ActiveRecord becomes ROM](03-activerecord-becomes-rom.md) | Keep the Postgres. Rewrite the objects. | `app/models/case.rb` | `app/repos/case_repo.rb` |
| [04. Port a map without two apps](04-port-a-map-without-two-apps.md) | Leaflet does not care about Rails | `MapsController` + `MapsHelper` | `/maps` on Hanami |
| [05. Port a review tool, not a gem](05-port-a-review-tool.md) | Dignity-first photo search | `FriendlyPhotos::CandidateSearch` | `EbWiki::FriendlyPhotos` |
| [06. Cut over without dual-running](06-cut-over-without-dual-running.md) | One Railway web service | Heroku Rails + preview apps | `hanami-web` only |

## How to film or write them

1. Show the Rails file first. Read it out loud. Name the Rails-only bits.
2. Open the Hanami file. Trace the same HTTP request.
3. Hit the live Hanami URL. Do not talk about theory you cannot click.
4. End with the constraint we kept: same slugs, same password hashes, same S3 keys.

## Demo URLs

- Cases: `/`, `/cases/:slug`
- Map: `/maps`
- Photo review: `/friendly_photos`, `/friendly_photos/:slug`
- Healthcheck: `/up`
