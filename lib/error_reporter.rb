# frozen_string_literal: true

# Reports errors to Sentry when loaded, otherwise Rollbar (config/initializers/rollbar.rb).
module ErrorReporter
  module_function

  def report(error, context = {})
    if sentry_loaded?
      Sentry.capture_exception(error, extra: context)
    else
      Rollbar.error(error, context)
    end
  end

  def sentry_loaded?
    defined?(Sentry) && Sentry.respond_to?(:capture_exception)
  end
  private_class_method :sentry_loaded?
end
