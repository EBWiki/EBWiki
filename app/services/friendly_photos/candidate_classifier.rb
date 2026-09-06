# frozen_string_literal: true

module FriendlyPhotos
  # Combines metadata heuristics with optional vision scoring.
  class CandidateClassifier
    include Service

    Result = Struct.new(:likely_mugshot, :reasons, :score, :ai_used, keyword_init: true)

    def call(hit:)
      metadata = MugshotClassifier.call(text: hit_text(hit))
      vision = VisionClassifier.call(hit: hit)
      combine(metadata, vision)
    end

    private

    def hit_text(hit)
      [hit.title, hit.description, hit.image_url, hit.page_url]
    end

    def combine(metadata, vision)
      Result.new(
        likely_mugshot: metadata.likely_mugshot || vision.likely_mugshot,
        reasons: (metadata.reasons + vision.reasons).uniq,
        score: metadata.score + vision.score,
        ai_used: vision.ai_used
      )
    end
  end
end
