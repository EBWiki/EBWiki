# frozen_string_literal: true

namespace :mpv_photo_import do
  desc 'Import link-only case photos from a Mapping Police Violence CSV (staging)'
  task run: :environment do
    csv_path = ENV.fetch('CSV_PATH', nil)
    abort 'Set CSV_PATH to the MPV export file path' if csv_path.blank?

    report = MpvPhotoImport::Importer.new(csv_path: csv_path).call
    puts report.to_h.to_json
  end
end
