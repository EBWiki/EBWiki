# frozen_string_literal: true

module Release
  # Sends smoke-check and release-tool failures to logs and configured trackers.
  class ErrorReporter
    def self.report(event:, message:, context: {})
      new.report(event: event, message: message, context: context)
    end

    def report(event:, message:, context: {})
      payload = {
        event: event,
        message: message,
        context: context,
        timestamp: Time.current.utc.iso8601
      }
      Rails.logger.error(payload.to_json)
      notify_rollbar(payload)
      notify_sentry(payload)
    end

    private

    def notify_rollbar(payload)
      return unless defined?(Rollbar) && Rollbar.respond_to?(:error)

      Rollbar.error(payload[:message], payload)
    rescue StandardError => e
      log_tracker_warning('rollbar', e)
    end

    def notify_sentry(payload)
      return unless defined?(Sentry) && Sentry.respond_to?(:capture_message)

      Sentry.capture_message(payload[:message], extra: payload)
    rescue StandardError => e
      log_tracker_warning('sentry', e)
    end

    def log_tracker_warning(tracker, error)
      Rails.logger.warn(
        { event: 'release_error_reporter', tracker: tracker, error: error.message }.to_json
      )
    end
  end
end
