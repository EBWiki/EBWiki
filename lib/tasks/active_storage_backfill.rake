# frozen_string_literal: true

namespace :active_storage do
  desc 'Backfill Case photos from CarrierWave avatars (DRY_RUN=1, LIMIT=n, ALLOW_MISSING=1)'
  task backfill_case_photos: :environment do
    dry_run = ENV['DRY_RUN'].to_s == '1'
    limit = ENV['LIMIT'].presence
    allow_missing = ENV['ALLOW_MISSING'].to_s == '1'

    counts = ActiveStorageBackfill::CasePhotos.call(dry_run: dry_run, limit: limit)
    puts ActiveStorageBackfill::CasePhotos.summary_line(counts)

    exit 1 if counts[:errors].to_i.positive?
    exit 1 if counts[:missing_file].to_i.positive? && !allow_missing
  end
end
