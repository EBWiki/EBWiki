# frozen_string_literal: true

namespace :active_storage do
  desc 'Backfill Case photos from CarrierWave avatars (idempotent; DRY_RUN=1, LIMIT=n)'
  task backfill_case_photos: :environment do
    dry_run = ENV['DRY_RUN'].to_s == '1'
    limit = ENV['LIMIT'].presence

    counts = ActiveStorageBackfill::CasePhotos.call(dry_run: dry_run, limit: limit)
    puts ActiveStorageBackfill::CasePhotos.summary_line(counts)
  end
end
