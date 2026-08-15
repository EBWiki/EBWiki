# frozen_string_literal: true

namespace :photos do
  desc 'Search Wikimedia for non-mugshot portraits of people in the database'
  task search_friendly: :environment do
    results = FriendlyPhotos::BatchSearch.call
    if ENV['FORMAT'] == 'json'
      puts JSON.pretty_generate(results)
    else
      results.each { |row| puts FriendlyPhotos::BatchSearch.summary_line(row) }
    end
  end

  desc 'Classify current case avatars as mugshot or unclassified from filenames'
  task classify_current: :environment do
    updated = FriendlyPhotos::CurrentAvatarClassifier.call
    puts "\nMarked #{updated} current avatars as mugshots."
  end
end
