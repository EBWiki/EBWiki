# Mapping Police Violence photo import

Link-only case photos from Mapping Police Violence (MPV) CSV exports. The importer stores URLs and credit text on `cases`; it never downloads or caches image bytes.

## Matching

- **Auto-accept:** normalized victim name, date of death, and state all match an EBWiki case exactly.
- **Review queue:** same date and state with a near name match, or two of three exact fields with the third off. Rows land in `case_mpv_photo_reviews` for staff confirmation.
- **Rejected:** mugshot or booking-site URLs (same host and text rules as `PhotoFinder::MugshotFilter` on the case-photo-finder branch).

Washington Post sources are out of scope for this importer.

## Usage

```ruby
report = MpvPhotoImport::Importer.new(csv_path: '/path/to/mpv.csv').call
report.to_h
# => { auto_matched:, review_queue:, rejected:, skipped:, error_count: }
```

Rake task (staging):

```bash
bin/rails mpv_photo_import:run CSV_PATH=/path/to/mpv.csv
```

Errors are logged and sent through `ErrorReporter` (Sentry when loaded, otherwise Rollbar).
