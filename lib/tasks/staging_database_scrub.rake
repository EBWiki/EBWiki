# frozen_string_literal: true

require 'staging_database_scrub'

namespace :staging_database do
  desc 'Scrub user personal data from a staging database copy'
  task scrub: :environment do
    StagingDatabaseScrub.scrub
    $stdout.puts 'Staging database scrub finished.'
  end

  desc 'Assert a scrubbed database has no remaining personal data'
  task assert: :environment do
    result = StagingDatabaseScrub.assert
    StagingDatabaseScrub::ReportPrinter.print_assertion_result(result)
    unless result.success?
      raise StagingDatabaseScrub::Asserter::AssertionFailedError,
            'Scrubbed database assertion failed'
    end
    $stdout.puts 'Scrubbed database assertion passed.'
  end
end
