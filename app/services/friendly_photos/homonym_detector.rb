# frozen_string_literal: true

module FriendlyPhotos
  # Flags Commons hits that likely depict a different historical person with the same name.
  class HomonymDetector
    include Service

    HISTORICAL_PATTERNS = [
      /\bsir\b/i,
      /\bbaron\b/i,
      /\blord\b/i,
      /\bnovelist\b/i,
      /\bpoet\b/i,
      /\bwriter\b/i,
      /\bstatue\b/i,
      /\bmonument\b/i,
      /\bbust of\b/i,
      /\bsculpture\b/i,
      /\bengraving\b/i,
      /\bhistorical figure\b/i,
      /18th century/i,
      /19th century/i,
      /\b\d{4}\s*[-–]\s*\d{4}\b/
    ].freeze

    Result = Struct.new(:likely_homonym, :reasons, :score_penalty, keyword_init: true)

    def call(text:, case_year: nil)
      haystack = Array(text).compact.join(' ')
      reasons = matching_labels(haystack)
      reasons << 'century mismatch' if century_mismatch?(haystack, case_year)

      Result.new(
        likely_homonym: reasons.any?,
        reasons: reasons.uniq,
        score_penalty: reasons.any? ? -25 : 0
      )
    end

    private

    def matching_labels(haystack)
      HISTORICAL_PATTERNS.filter_map do |pattern|
        match = haystack.match(pattern)
        match&.to_s&.downcase
      end.uniq
    end

    def century_mismatch?(haystack, case_year)
      return false if case_year.blank?

      case_year = case_year.to_i
      return false unless case_year >= 1950

      haystack.match?(/\b(1[0-8]\d{2}|19[0-4]\d)\b/)
    end
  end
end
