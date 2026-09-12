# frozen_string_literal: true

module FriendlyPhotos
  # Builds the CandidateSearch result plus editor-visible AI warnings.
  class SearchOutcome
    include Service

    def call(records:, planner_ai_used:, decorated:)
      vision_ai_used_count = decorated.count { |hit| hit[:vision_ai_used] }
      vision_failed_count = decorated.count { |hit| hit[:vision_failed] }

      CandidateSearch::Result.new(
        records: records,
        planner_ai_used: planner_ai_used,
        vision_ai_used_count: vision_ai_used_count,
        vision_failed_count: vision_failed_count,
        warnings: warnings(planner_ai_used, vision_ai_used_count, vision_failed_count, records)
      )
    end

    private

    def warnings(planner_ai_used, vision_ai_used_count, vision_failed_count, records)
      [
        planner_warning(planner_ai_used),
        vision_warning(vision_ai_used_count, records),
        failure_warning(vision_failed_count)
      ].compact
    end

    def planner_warning(planner_ai_used)
      return unless AiConfig.require_ai? && !planner_ai_used

      'Planner AI did not run on this search.'
    end

    def vision_warning(vision_ai_used_count, records)
      return unless AiConfig.require_ai? && records.any? && vision_ai_used_count.zero?

      'Vision AI did not verify any candidates.'
    end

    def failure_warning(vision_failed_count)
      return unless vision_failed_count.positive?

      "#{vision_failed_count} candidate(s) had vision API failures."
    end
  end
end
