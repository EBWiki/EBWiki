# frozen_string_literal: true

module Release
  class SmokeCheck
    module FailureReporting
      private

      def log_step(path, status)
        payload = {
          event: 'release_smoke_check',
          step: path,
          http_status: status,
          base_url: @log_base_url
        }
        @logger.info(payload.to_json)
      end

      def log_success
        payload = { event: 'release_smoke_check', result: 'ok', base_url: @log_base_url }
        @logger.info(payload.to_json)
      end

      def report_failure(error)
        message = "Release smoke check failed at #{error.step}: #{error.message}"
        @error_reporter.report(
          event: 'release_smoke_check_failed',
          message: message,
          context: { step: error.step, base_url: @log_base_url }
        )
        warn(message)
      end
    end
  end
end
