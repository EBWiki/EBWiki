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

  desc 'Classify current case avatars from filenames (dry-run unless APPLY=1)'
  task classify_current: :environment do
    apply = ActiveModel::Type::Boolean.new.cast(ENV.fetch('APPLY', '0'))

    if apply
      updated = FriendlyPhotos::CurrentAvatarClassifier.call
      puts "\nMarked #{updated} current photos as needing a healthier photo."
    else
      counts = FriendlyPhotos::CurrentAvatarClassifier.call(dry_run: true)
      puts "\nDry run (no database writes)."
      puts "  Would mark as mugshot (needs healthier photo): #{counts[:would_mark_mugshot]}"
      puts "  Unchanged (no update this run):                 #{counts[:unchanged]}"
      puts "\nRe-run with APPLY=1 to persist avatar_kind on matching cases."
    end
  end
end
