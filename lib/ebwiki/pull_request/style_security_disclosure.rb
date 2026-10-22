# frozen_string_literal: true

module Ebwiki
  module PullRequest
    class StyleSecurityDisclosure
      SECTION_HEADING = '## Style/security rule changes'

      RULE_PATH_PATTERNS = [
        '.rubocop.yml',
        '.rubocop.yaml',
        '.rubocop_todo.yml',
        'config/brakeman.ignore',
        'config/brakeman.baseline.json',
        'Gemfile',
        'Gemfile.lock'
      ].freeze

      def initialize(body:, changed_files:)
        @body = body.to_s
        @changed_files = changed_files
      end

      def required?
        rule_related_changes.any?
      end

      def satisfied?
        return true unless required?

        !section_content.strip.empty? && section_content.strip.casecmp('none') != 0
      end

      def failure_message
        return nil if satisfied?

        files = rule_related_changes.join(', ')
        <<~MSG.strip
          #{SECTION_HEADING} is required because this pull request touches #{files}.
          Fill in the section with the exact cop or check, before and after, why, affected paths,
          exclusion or baseline updates, and how you verified the change. Write None only when no
          rule files changed.
        MSG
      end

      def rule_related_changes
        @rule_related_changes ||= @changed_files.select do |path|
          RULE_PATH_PATTERNS.include?(path) || path.start_with?('.rubocop')
        end
      end

      private

      def section_content
        return nil unless @body.include?(SECTION_HEADING)

        after = @body.split(SECTION_HEADING, 2).last
        after.split(/^## /, 2).first.to_s.strip
      end
    end
  end
end
