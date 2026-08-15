# frozen_string_literal: true

namespace :photos do
  desc 'Search Wikimedia for non-mugshot portraits of people in the database'
  task search_friendly: :environment do
    results = FriendlyPhotos::BatchSearch.call
    FriendlyPhotos::BatchSearch.print_results(results)
  end

  desc 'Classify current case avatars as mugshot or unclassified from filenames'
  task classify_current: :environment do
    updated = FriendlyPhotos::CurrentAvatarClassifier.call
    puts "\nMarked #{updated} current avatars as mugshots."
  end
end
