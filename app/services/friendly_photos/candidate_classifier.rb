# frozen_string_literal: true

module FriendlyPhotos
  # Combines metadata heuristics with optional vision scoring.
  class CandidateClassifier
    include Service

    Result = Struct.new(:likely_mugshot, :reasons, :score, :ai_used, keyword_init: true)

    def call(hit:)
      text = [hit.title, hit.description, hit.image_url, hit.page_url]
      metadata = MugshotClassifier.call(text: text)
      vision = VisionClassifier.call(hit: hit)

      likely_mugshot = metadata.likely_mugshot || vision.likely_mugshot
      reasons = (metadata.reasons + vision.reasons).uniq
      score = metadata.score + vision.score

      Result.new(
        likely_mugshot: likely_mugshot,
        reasons: reasons,
        score: score,
        ai_used: vision.ai_used
      )
    end
  end
end
