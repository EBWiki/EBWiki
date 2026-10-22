# frozen_string_literal: true

require 'json'

module Ebwiki
  module PreCommit
    class BrakemanRunner
      BASELINE_PATH = 'config/brakeman.baseline.json'

      def initialize(repo_root:, git: GitCommand.new(repo_root: repo_root))
        @repo_root = repo_root
        @git = git
      end

      def run_full_repo!(logger: ->(*) {})
        require 'brakeman'
      rescue LoadError => e
        raise ToolMissingError.new(
          'Brakeman is not available. Run `bundle install` in the repo root.',
          instructions: e.message
        )
      else
        tracker = scan_app(@repo_root)
        ensure_scanner_clean!(tracker, logger)
        ensure_warnings_approved!(tracker.filtered_warnings, logger)
        logger.call(:info, 'Brakeman passed for repository tree.')
        :passed
      end

      def run(staged:, logger: ->(*) {})
        reason = staged.skip_reason_for('Brakeman')
        if reason
          logger.call(:info, reason)
          return :skipped
        end

        unless staged.brakeman_needed?
          logger.call(:info, 'No security-relevant paths staged; skipping Brakeman.')
          return :skipped
        end

        require 'brakeman'
      rescue LoadError => e
        raise ToolMissingError.new(
          'Brakeman is not available. Run `bundle install` in the repo root.',
          instructions: e.message
        )
      else
        Snapshot.new(repo_root: @repo_root, git: @git).with_staged_app do |app_root|
          tracker = scan_app(app_root)
          ensure_scanner_clean!(tracker, logger)
          ensure_warnings_approved!(tracker.filtered_warnings, logger)
          logger.call(:info, 'Brakeman passed for staged app snapshot.')
          :passed
        end
      end

      private

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

        message = errors.map { |e| e[:error] || e['error'] || e.to_s }.join("\n")
        logger.call(:error, message)
        raise ToolFailedError.new('Brakeman encountered scanner errors.', instructions: message)
      end

      def ensure_warnings_approved!(warnings, logger)
        baseline = load_baseline
        approved = baseline.fetch('approved_fingerprints', [])
        ignore_path = File.join(@repo_root, 'config/brakeman.ignore')
        ignored = ignored_fingerprints(ignore_path)

        unapproved = warnings.reject do |warning|
          fingerprint = warning.fingerprint
          approved.include?(fingerprint) || ignored.include?(fingerprint)
        end
        return if unapproved.empty?

        lines = unapproved.map do |warning|
          "#{warning.file}:#{warning.line} #{warning.warning_type} (#{warning.fingerprint})"
        end
        body = lines.join("\n")
        logger.call(:error, body)
        raise ToolFailedError.new(
          'Brakeman reported unapproved warnings for the staged snapshot.',
          instructions: body
        )
      end

      def load_baseline
        path = File.join(@repo_root, BASELINE_PATH)
        JSON.parse(File.read(path))
      rescue Errno::ENOENT
        raise UserFacingError.new(
          "Missing #{BASELINE_PATH}.",
          instructions: 'Add a baseline file listing approved warning fingerprints.'
        )
      rescue JSON::ParserError => e
        raise UserFacingError.new("Invalid #{BASELINE_PATH}.", instructions: e.message)
      end

      def ignored_fingerprints(ignore_path)
        return [] unless File.file?(ignore_path)

        data = JSON.parse(File.read(ignore_path))
        Array(data['ignored_warnings']).filter_map { |entry| entry['fingerprint'] }
      rescue JSON::ParserError
        []
      end
    end
  end
end
