# frozen_string_literal: true

require_relative 'plain'

module Release
  # Configures Rollbar for standalone release CLIs when a token is present.
  module RollbarSetup
    module_function

    def configure!
      token = ENV.fetch('ROLLBAR_ACCESS_TOKEN', nil)
      return unless Plain.present?(token)

      require 'rollbar'
      Rollbar.configure do |config|
        config.access_token = token
        config.environment = ENV.fetch('ROLLBAR_ENV', 'release-smoke-check')
        config.enabled = true
      end
    end
  end
end
