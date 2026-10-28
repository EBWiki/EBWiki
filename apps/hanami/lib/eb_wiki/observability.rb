# frozen_string_literal: true

require "json"

module EbWiki
  # Structured logs and optional Sentry reporting for Hanami lib code.
  module Observability
    module_function

    def report(event:, error: nil, **context)
      payload = {
        event: event,
        component: "hanami",
        **context
      }
      if error
        payload[:error_class] = error.class.name
        payload[:error_message] = error.message
      end
      warn(payload.to_json)

      return unless sentry_ready?

      if error
        Sentry.capture_exception(error, extra: context)
      else
        Sentry.capture_message(event.to_s, level: :warning, extra: context)
      end
    end

    def sentry_ready?
      return @sentry_ready if defined?(@sentry_ready)

      @sentry_ready = begin
        require "sentry-ruby"
        dsn = ENV["SENTRY_DSN"].to_s.strip
        if !dsn.empty? && Sentry.configuration.dsn.nil?
          Sentry.init do |config|
            config.dsn = dsn
            config.enabled_environments = %w[production staging]
            config.send_default_pii = false
          end
        end
        !Sentry.configuration.dsn.nil?
      rescue LoadError
        false
      end
    end
  end
end
