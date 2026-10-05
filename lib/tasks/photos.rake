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
end
