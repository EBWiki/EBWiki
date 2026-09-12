# frozen_string_literal: true

module FriendlyPhotos
  # Scores unique search hits and optionally runs batched vision.
  class HitDecorator
    include Service

    def call(raw_hits:, this_case:, planner_ai_used:)
      scored = sort_by_metadata(raw_hits.uniq(&:image_url), this_case.date&.year)
      vision_urls = vision_url_set(scored)
      scored.map { |entry| decorate_entry(entry, this_case, planner_ai_used, vision_urls) }
    end

    def vision_url_set(scored)
      scored.first(SearchLimits::VISION_LIMIT).to_set { |entry| entry[:hit].image_url }
    end

    def decorate_entry(entry, this_case, planner_ai_used, vision_urls)
      run_vision = vision_urls.include?(entry[:hit].image_url)
      attrs_for(entry[:hit], this_case, planner_ai_used, run_vision)
    end

    private

    def sort_by_metadata(hits, case_year)
      hits.map { |hit| { hit: hit, metadata_score: metadata_score(hit, case_year) } }
          .sort_by { |entry| -entry[:metadata_score] }
    end

    def metadata_score(hit, case_year)
      text = hit_text(hit)
      MugshotClassifier.call(text: text).score +
        HomonymDetector.call(text: text, case_year: case_year).score_penalty
    end

    def attrs_for(hit, this_case, planner_ai_used, run_vision)
      classification = CandidateClassifier.call(
        hit: hit,
        run_vision: run_vision,
        case_year: this_case.date&.year
      )
      hit_to_attrs(hit, this_case.subject_display_name, classification, planner_ai_used)
    end

    def hit_text(hit)
      [hit.title, hit.description, hit.page_url]
    end

    def hit_to_attrs(hit, name, classification, planner_ai_used)
      hit.to_h.merge(
        subject_name: name,
        likely_mugshot: classification.likely_mugshot,
        likely_homonym: classification.likely_homonym,
        score: classification.score,
        notes: classification.reasons.join(', ').presence,
        planner_ai_used: planner_ai_used,
        vision_ai_used: classification.vision_ai_used,
        vision_failed: classification.vision_failed
      ).except(:description)
    end
  end
end
