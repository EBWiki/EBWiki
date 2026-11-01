# frozen_string_literal: true

namespace :staging do
  desc 'Add three demo cases on staging. Needs CONFIRM_STAGING_SAMPLE_CONTENT=add-sample-cases. Never run from a deploy.'
  task sample_content: :environment do
    abort('staging:sample_content runs only when RAILS_ENV=staging') unless Rails.env.staging?
    unless ENV['CONFIRM_STAGING_SAMPLE_CONTENT'] == 'add-sample-cases'
      abort('staging:sample_content adds fake cases to the staging data. ' \
            'Set CONFIRM_STAGING_SAMPLE_CONTENT=add-sample-cases to run it on purpose.')
    end

    require Rails.root.join('lib/staging_sample_content')
    StagingSampleContent.ensure!
  end
end
