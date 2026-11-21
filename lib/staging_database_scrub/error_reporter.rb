# frozen_string_literal: true

module StagingDatabaseScrub
  module ErrorReporter
    module_function

    def report(error, **context)
      payload = { scrub: 'staging_database', **context }
      Rollbar.error(error, payload) if rollbar_enabled?
      Rails.logger.error(
        "[staging_database_scrub] #{error.class}: #{error.message} #{payload.inspect}"
      )
    end

    def rollbar_enabled?
      defined?(Rollbar) && Rollbar.configuration.enabled != false
    end
  end
end
