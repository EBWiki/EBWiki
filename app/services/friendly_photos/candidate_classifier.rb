# frozen_string_literal: true

module FriendlyPhotos
  # Combines metadata heuristics with optional batched vision scoring.
  class CandidateClassifier
    include Service

    Result = Struct.new(
      :likely_mugshot,
      :likely_homonym,
      :reasons,
      :score,
      :vision_ai_used,
      :vision_failed,
      keyword_init: true
    )

    def call(hit:, run_vision: true, case_year: nil)
      metadata = MugshotClassifier.call(text: hit_text(hit))
      homonym = HomonymDetector.call(text: hit_text(hit), case_year: case_year)
      vision = vision_result(hit, run_vision)
      combine(metadata, homonym, vision)
    end

    private

    def hit_text(hit)
      [hit.title, hit.description, hit.image_url, hit.page_url]
    end

    def vision_result(hit, run_vision)
      return VisionClassifier.skipped_result unless run_vision

      VisionClassifier.call(hit: hit)
    end

    def combine(metadata, homonym, vision)
      Result.new(
        likely_mugshot: metadata.likely_mugshot || vision.likely_mugshot,
        likely_homonym: homonym.likely_homonym,
        reasons: combined_reasons(metadata, homonym, vision),
        score: combined_score(metadata, homonym, vision),
        vision_ai_used: vision.ai_used,
        vision_failed: vision.failed
      )
    end

    def combined_reasons(metadata, homonym, vision)
      (metadata.reasons + homonym.reasons + vision.reasons).uniq
    end

    def combined_score(metadata, homonym, vision)
      metadata.score + homonym.score_penalty + vision.score
    end
  end
end
