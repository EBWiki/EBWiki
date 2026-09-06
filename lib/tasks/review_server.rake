# frozen_string_literal: true

namespace :review do
  desc 'Seed disposable editor login and friendly-photo demo cases for PR preview'
  task seed: :environment do
    ReviewDbConnection.reset_pool! if ENV['REVIEW_SERVER'] == '1'
    FriendlyPhotos::E2eSeed.call
    puts 'Review server seeded.'
    puts "Editor login: #{FriendlyPhotos::E2eSeed::EMAIL}"
    puts "Password: #{FriendlyPhotos::E2eSeed::PASSWORD}"
  end
end
