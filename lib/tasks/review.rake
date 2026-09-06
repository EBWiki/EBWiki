# frozen_string_literal: true

namespace :review do
  desc 'Migrate, clear stale prepared statements, and seed review fixtures (single process)'
  task deploy_prepare: :environment do
    ActiveRecord::Tasks::DatabaseTasks.migrate
    ReviewDbConnection.reset_pool!
    Rake::Task['review:seed'].invoke
  end

  desc 'Seed disposable editor login and friendly-photo demo cases for PR preview'
  task seed: :environment do
    ReviewDbConnection.reset_pool!
    FriendlyPhotos::E2eSeed.call
    puts 'Review server seeded.'
    puts "Editor login: #{FriendlyPhotos::E2eSeed::EMAIL}"
    puts "Password: #{FriendlyPhotos::E2eSeed::PASSWORD}"
  end
end
