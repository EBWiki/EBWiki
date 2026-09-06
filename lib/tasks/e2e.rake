# frozen_string_literal: true

namespace :e2e do
  desc 'Seed deterministic friendly-photo data for Playwright'
  task seed_friendly_photos: :environment do
    FriendlyPhotos::E2eSeed.call
    puts 'Seeded e2e friendly photo fixtures.'
  end
end
