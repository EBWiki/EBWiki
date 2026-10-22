# frozen_string_literal: true

require 'staging_database_scrub/column_catalog'
require 'staging_database_scrub/error_reporter'
require 'staging_database_scrub/production_guard'
require 'staging_database_scrub/report_printer'
require 'staging_database_scrub/scrubber_steps'
require 'staging_database_scrub/scrubber'
require 'staging_database_scrub/asserter'

module StagingDatabaseScrub
  module_function

  def scrub(**)
    Scrubber.new(**).run
  end

  def assert(**)
    Asserter.new(**).run
  end

  def checked_columns
    ColumnCatalog.all_checked_columns
  end
end
