# frozen_string_literal: true

require 'json'

module Ebwiki
  module PreCommit
    class BrakemanBaseline
      BASELINE_PATH = 'config/brakeman.baseline.json'

      def initialize(repo_root:)
        @repo_root = repo_root
      end

      def approved?(fingerprint, ignore_path: File.join(@repo_root, 'config/brakeman.ignore'))
        approved_fingerprints.include?(fingerprint) ||
          ignored_fingerprints(ignore_path).include?(fingerprint)
      end

      def reject_unapproved!(warnings, logger:)
        unapproved = warnings.reject { |warning| approved?(warning.fingerprint) }
        return if unapproved.empty?

        body = unapproved.map { |warning| format_warning(warning) }.join("\n")
        logger.call(:error, body)
        raise ToolFailedError.new(
          'Brakeman reported unapproved warnings for the staged snapshot.',
          instructions: body
        )
      end

      private

      def format_warning(warning)
        "#{warning.file}:#{warning.line} #{warning.warning_type} (#{warning.fingerprint})"
      end

      def approved_fingerprints
        @approved_fingerprints ||= load_baseline.fetch('approved_fingerprints', [])
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
