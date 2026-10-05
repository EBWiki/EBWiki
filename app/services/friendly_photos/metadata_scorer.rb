# frozen_string_literal: true

module FriendlyPhotos
  # Scores image metadata for ranking (portraits up, institutional sources down).
  class MetadataScorer
    include Service

    INSTITUTIONAL_PATTERNS = [
      /\bbooking\b/i,
      /\binmate\b/i,
      /\bjail\b/i,
      /\bprison\b/i,
      /department of corrections/i,
      /\bcorrections\b/i,
      /height.?chart/i,
      /arrest(ed)?(\s*photo)?/i,
      /detention/i,
      /inmate\s*id/i,
      /booking\s*number/i,
      /sheriff.+(booking|photo)/i
    ].freeze

    PORTRAIT_PATTERNS = [
      /\bportrait\b/i,
      /family\s*photo/i,
      /yearbook/i,
      /graduation/i,
      /\bsmiling\b/i,
      /memorial/i,
      /headshot/i,
      /photograph of/i
    ].freeze
    NEWS_STILL_PATTERNS = [
      /body.?cam/i,
      /crime\s*scene/i,
      /incident(\s*photo)?/i,
      /surveillance/i,
      /protest\s*photo/i
    ].freeze

    Result = Struct.new(:reasons, :score, keyword_init: true)

    def call(text:)
      haystack = Array(text).compact.join(' ')
      institutional_hits = matching_labels(haystack, INSTITUTIONAL_PATTERNS)
      portrait_hits = matching_labels(haystack, PORTRAIT_PATTERNS)
      news_hits = matching_labels(haystack, NEWS_STILL_PATTERNS)
      score = (portrait_hits.size * 3) - (institutional_hits.size * 5) - news_hits.size

      Result.new(
        reasons: institutional_hits + news_hits,
        score: score
      )
    end

    private

    def matching_labels(haystack, patterns)
      patterns.filter_map do |pattern|
        match = haystack.match(pattern)
        match&.to_s&.downcase
      end.uniq
    end
  end
end
