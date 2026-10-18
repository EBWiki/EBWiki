# frozen_string_literal: true

require 'json'

require_relative 'plain'

module Release
  # Configures Rollbar for standalone release CLIs when a token is present.
  module RollbarSetup
    module_function

    def configure!
      token = ENV.fetch('ROLLBAR_ACCESS_TOKEN', nil)
      return unless Plain.present?(token)

      apply_rollbar_config(token)
    rescue LoadError => e
      log_load_error(e)
    end

    def apply_rollbar_config(token)
      require_rollbar
      Rollbar.configure do |config|
        config.access_token = token
        config.environment = ENV.fetch('ROLLBAR_ENV', 'release-smoke-check')
        config.enabled = true
        config.use_async = false
      end
    end

    def log_load_error(error)
      warn(
        {
          event: 'rollbar_setup',
          message: 'Rollbar gem is not available',
          error: error.message
        }.to_json
      )
    end

    def require_rollbar
      require 'rollbar'
    end
  end
end
