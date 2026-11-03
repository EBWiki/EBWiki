# frozen_string_literal: true

namespace :photo_search do
  namespace :review_database do
    desc 'Scrub contributor PII on the database pointed at by EBWIKI_REVIEW_DATABASE_URL (Doppler)'
    task scrub: :environment do
      url = ENV.fetch('EBWIKI_REVIEW_DATABASE_URL', nil)
      abort('Set EBWIKI_REVIEW_DATABASE_URL from Doppler before running scrub.') if url.blank?

      PhotoSearch::ReviewDatabaseConnection.with_url(url) do
        PhotoSearch::ReviewDatabaseScrub.scrub!
        puts 'Scrub finished on EBWIKI_REVIEW_DATABASE_URL.'
      end
    end

    desc 'Assert scrubbed review database (EBWIKI_REVIEW_DATABASE_URL in Doppler)'
    task assert: :environment do
      url = ENV.fetch('EBWIKI_REVIEW_DATABASE_URL', nil)
      abort('Set EBWIKI_REVIEW_DATABASE_URL from Doppler before running assert.') if url.blank?

      PhotoSearch::ReviewDatabaseConnection.with_url(url) do
        result = PhotoSearch::ReviewDatabaseAssertions.run!
        result.checks.each do |check|
          puts "#{check[:name]}: #{check[:actual]}"
        end
        puts 'All scrub assertions passed.'
      end
    end

    desc 'Report case count on staging DATABASE_URL after scrubbed load (expect 4033)'
    task staging_report: :environment do
      url = ENV.fetch('DATABASE_URL', nil)
      abort('Set DATABASE_URL from Doppler ebwiki/stg before running staging_report.') if url.blank?

      PhotoSearch::ReviewDatabaseConnection.with_url(url) do
        report = PhotoSearch::StagingCaseLoader.report
        puts "case_count=#{report[:case_count]} expected=#{report[:expected_case_count]}"
        unless report[:matches_expected]
          abort('Case count does not match expected ebwiki-review copy.')
        end
      end
    end
  end
end
