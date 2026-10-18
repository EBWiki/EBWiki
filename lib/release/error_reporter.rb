# frozen_string_literal: true

require 'logger'
require 'time'

require_relative 'plain'
require_relative 'rollbar_setup'

module Release
  # Sends smoke-check failures to logs and Rollbar when configured.
  class ErrorReporter
    def self.report(event:, message:, context: {})
      new.report(event: event, message: message, context: context)
    end

    def report(event:, message:, context: {})
      payload = {
        event: event,
        message: message,
        context: context,
        timestamp: timestamp
      }
      logger.error(payload.to_json)
      RollbarSetup.configure!
      notify_rollbar(payload)
    end

    private

    def logger
      return Rails.logger if defined?(Rails) && Rails.respond_to?(:logger)

      @logger ||= Logger.new($stderr)
    end

    def timestamp
      Time.now.utc.iso8601
    end

    def notify_rollbar(payload)
      return unless Plain.present?(ENV.fetch('ROLLBAR_ACCESS_TOKEN', nil))
      return unless defined?(Rollbar) && Rollbar.respond_to?(:error)

      Rollbar.error(payload[:message], payload)
    rescue StandardError => e
      logger.warn(
        { event: 'release_error_reporter', tracker: 'rollbar', error: e.message }.to_json
      )
    end
  end
end
