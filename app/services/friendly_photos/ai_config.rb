# frozen_string_literal: true

module FriendlyPhotos
  # Reads AI provider settings from the environment.
  class AiConfig
    OPENAI_MODEL = ENV.fetch('FRIENDLY_PHOTOS_OPENAI_MODEL', 'gpt-4o-mini')
    ANTHROPIC_MODEL = ENV.fetch('FRIENDLY_PHOTOS_ANTHROPIC_MODEL', 'claude-3-5-haiku-latest')

    class << self
      def enabled?
        provider.present? && !stubbed?
      end

      def require_ai?
        ENV['REVIEW_SERVER'] == '1' || ENV['FRIENDLY_PHOTOS_REQUIRE_AI'] == '1'
      end

      def provider
        return :openai if ENV['OPENAI_API_KEY'].present?
        return :anthropic if ENV['ANTHROPIC_API_KEY'].present?

        nil
      end

      def stubbed?
        ENV['FRIENDLY_PHOTOS_STUB_AI'] == '1'
      end

      def status_label
        return 'stubbed (deterministic test AI)' if stubbed?
        return 'required but key missing' if require_ai? && !enabled?
        return "#{provider} (#{model_name}) — verify per-candidate badges" if enabled?

        'not configured (local dev without API key)'
      end

      def model_name
        case provider
        when :openai then OPENAI_MODEL
        when :anthropic then ANTHROPIC_MODEL
        else
          'none'
        end
      end

      def enforce_planner!(planner_ai_used)
        return if !require_ai? || planner_ai_used || stubbed?

        raise AiError, 'Search planner did not run (AI required on this server).'
      end
    end
  end
end
