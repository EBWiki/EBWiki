# frozen_string_literal: true

namespace :review do
  desc 'Create sessions table if a historic dump omitted it'
  task ensure_sessions: :environment do
    ReviewSessionsTable.ensure!
    puts 'Review sessions table ensured.'
  end

  desc 'Migrate, clear stale prepared statements, and seed review fixtures (single process)'
  task deploy_prepare: :environment do
    ActiveRecord::Tasks::DatabaseTasks.migrate
    ReviewSessionsTable.ensure!
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
