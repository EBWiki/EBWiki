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

      require_rollbar
      Rollbar.configure do |config|
        config.access_token = token
        config.environment = ENV.fetch('ROLLBAR_ENV', 'release-smoke-check')
        config.enabled = true
        config.use_async = false
      end
    rescue LoadError => e
      warn(
        {
          event: 'rollbar_setup',
          message: 'Rollbar gem is not available',
          error: e.message
        }.to_json
      )
    end

    def require_rollbar
      require 'rollbar'
    end
  end
end
