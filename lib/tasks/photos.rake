# frozen_string_literal: true

namespace :photos do
  desc 'Search Wikimedia and Openverse for healthy profile pictures'
  task search_friendly: :environment do
    results = FriendlyPhotos::BatchSearch.call
    if ENV['FORMAT'] == 'json'
      puts JSON.pretty_generate(results)
    else
      results.each { |row| puts FriendlyPhotos::BatchSearch.summary_line(row) }
    end
  end

  desc 'Classify current case avatars from filenames'
  task classify_current: :environment do
    updated = FriendlyPhotos::CurrentAvatarClassifier.call
    puts "\nMarked #{updated} current photos as needing a healthier photo."
  end
end
