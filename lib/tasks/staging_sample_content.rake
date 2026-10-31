# frozen_string_literal: true

namespace :staging do
  desc "Ensure idempotent demo cases on the Railway staging site (staging env only)"
  task sample_content: :environment do
    unless Rails.env.staging?
      abort("staging:sample_content runs only when RAILS_ENV=staging")
    end

    require Rails.root.join("lib/staging_sample_content")
    StagingSampleContent.ensure!
  end
end
