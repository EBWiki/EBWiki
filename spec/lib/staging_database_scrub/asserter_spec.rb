# frozen_string_literal: true

require 'rails_helper'
require 'staging_database_scrub'

RSpec.describe StagingDatabaseScrub::Asserter do
  it 'reports zero violations on a scrubbed database' do
    create(:user, email: 'real.person@company.com')
    create(:case, title: 'Case count check')
    ENV['EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED'] = 'true'
    StagingDatabaseScrub.scrub

    config = ActiveRecord::Base.connection_db_config.configuration_hash
    url = format(
      'postgresql://%<username>s:%<password>s@%<host>s/%<database>s',
      username: config[:username],
      password: config[:password],
      host: config[:host],
      database: config[:database]
    )
    result = described_class.new(database_url: url).run
    expect(result.success?).to be(true)
    expect(result.case_count).to be >= 1
  ensure
    ENV.delete('EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED')
  end
end

RSpec.describe StagingDatabaseScrub::ProductionGuard do
  it 'refuses to scrub without EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED' do
    ENV.delete('EBWIKI_STAGING_DATABASE_SCRUB_ALLOWED')

    expect do
      described_class.enforce
    end.to raise_error(StagingDatabaseScrub::ProductionGuard::RefusedError)
  end
end
