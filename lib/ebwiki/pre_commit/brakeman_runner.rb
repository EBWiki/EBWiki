# frozen_string_literal: true

module Ebwiki
  module PreCommit
    class BrakemanRunner
      def initialize(repo_root:, git: GitCommand.new(repo_root: repo_root))
        @repo_root = repo_root
        @git = git
        @baseline = BrakemanBaseline.new(repo_root: repo_root)
      end

      def run_full_repo!(logger: ->(*) {})
        with_brakeman { |tracker| finish_scan!(tracker, logger, 'repository tree') }
      end

      def run(staged:, logger: ->(*) {})
        if staged.skip_reason_for('Brakeman')
          return logger.call(:info,
                             staged.skip_reason_for('Brakeman')) || :skipped
        end
        unless staged.brakeman_needed?
          return logger.call(:info,
                             'No security-relevant paths staged; skipping Brakeman.') || :skipped
        end

        Snapshot.new(repo_root: @repo_root, git: @git).with_staged_app do |app_root|
          with_brakeman(app_root) { |tracker| finish_scan!(tracker, logger, 'staged app snapshot') }
        end
      end

      private

      def with_brakeman(app_root = @repo_root)
        require 'brakeman'
        yield scan_app(app_root)
      rescue LoadError => e
        raise ToolMissingError.new(
          'Brakeman is not available. Run `bundle install` in the repo root.',
          instructions: e.message
        )
      end

      def finish_scan!(tracker, logger, label)
        ensure_scanner_clean!(tracker, logger)
        @baseline.reject_unapproved!(tracker.filtered_warnings, logger: logger)
        logger.call(:info, "Brakeman passed for #{label}.")
        :passed
      end

      def scan_app(app_root)
        Brakeman.run(
          app_path: app_root,
          print_report: false,
          min_confidence: 2,
          exit_on_warn: false,
          exit_on_error: false,
          run_all_checks: true,
          quiet: true
        )
      end

      def ensure_scanner_clean!(tracker, logger)
        errors = tracker.instance_variable_get(:@errors) || []
        return if errors.empty?

        message = errors.map { |error| error[:error] || error['error'] || error.to_s }.join("\n")
        logger.call(:error, message)
        raise ToolFailedError.new('Brakeman encountered scanner errors.', instructions: message)
      end
    end
  end
end
