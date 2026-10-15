# frozen_string_literal: true

namespace :photo_finder do
  desc 'Enqueue web photo search for cases without a custom photo (LIMIT defaults to 10)'
  task enqueue_missing: :environment do
    limit = ENV.fetch('LIMIT', 10).to_i
    Case.missing_custom_photo.includes(:subjects, :state).limit(limit).find_each do |case_record|
      PhotoFinderJob.perform_later(case_record.id)
      puts "Enqueued photo finder for case #{case_record.id} (#{case_record.title})"
    end
  end
end
