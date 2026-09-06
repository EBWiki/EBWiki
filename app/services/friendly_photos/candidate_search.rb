# frozen_string_literal: true

module FriendlyPhotos
  # Finds non-mugshot Wikimedia and Openverse portraits for a case subject.
  class CandidateSearch
    include Service

    Result = Struct.new(
      :records,
      :planner_ai_used,
      :vision_ai_used_count,
      :vision_failed_count,
      :warnings,
      keyword_init: true
    )

    def initialize(
      client: WikimediaClient.new,
      openverse: OpenverseClient.new,
      planner: SearchPlanner.new
    )
      @client = client
      @openverse = openverse
      @planner = planner
    end

    def call(this_case:, persist: true)
      planner_ai_used = false
      raw_hits = []

      subject_names(this_case).each do |name|
        plan = planner.call(
          name: name,
          city: this_case.city,
          year: this_case.date&.year,
          slug: this_case.slug
        )
        planner_ai_used ||= plan.ai_used
        plan.queries.each { |query| raw_hits.concat(combined_hits(query)) }
      end

      AiConfig.enforce_planner!(planner_ai_used)

      decorated = decorate_hits(raw_hits, this_case, planner_ai_used)
      records = persist ? persist_hits(this_case, decorated) : []
      build_result(records, planner_ai_used, decorated)
    end

    private

    attr_reader :client, :openverse, :planner

    def subject_names(this_case)
      names = this_case.subjects.reload.filter_map { |subject| subject.name.presence }
      names << this_case.title if names.empty?
      names.uniq
    end

    def combined_hits(query)
      limit = SearchLimits::HIT_LIMIT_PER_QUERY
      (client.search(query: query, limit: limit) + openverse.search(query: query, limit: limit))
        .uniq(&:image_url)
        .reject { |hit| SourcePolicy.excluded_hit?(hit) }
    end

    def decorate_hits(raw_hits, this_case, planner_ai_used)
      unique_hits = raw_hits.uniq(&:image_url)
      metadata_scored = unique_hits.map do |hit|
        {
          hit: hit,
          metadata_score: metadata_score(hit, this_case.date&.year)
        }
      end
      metadata_scored.sort_by! { |entry| -entry[:metadata_score] }

      vision_urls = metadata_scored.first(SearchLimits::VISION_LIMIT)
                                   .to_set { |entry| entry[:hit].image_url }

      metadata_scored.map do |entry|
        attrs_for(entry[:hit], this_case, planner_ai_used, vision_urls.include?(entry[:hit].image_url))
      end
    end

    def metadata_score(hit, case_year)
      text = hit_text(hit)
      MugshotClassifier.call(text: text).score +
        HomonymDetector.call(text: text, case_year: case_year).score_penalty
    end

    def attrs_for(hit, this_case, planner_ai_used, run_vision)
      name = this_case.subject_display_name
      classification = CandidateClassifier.call(
        hit: hit,
        run_vision: run_vision,
        case_year: this_case.date&.year
      )
      hit_to_attrs(hit, name, classification, planner_ai_used)
    end

    def hit_text(hit)
      [hit.title, hit.description, hit.page_url]
    end

    def hit_to_attrs(hit, name, classification, planner_ai_used)
      notes = classification.reasons.join(', ').presence

      hit.to_h.merge(
        subject_name: name,
        likely_mugshot: classification.likely_mugshot,
        likely_homonym: classification.likely_homonym,
        score: classification.score,
        notes: notes,
        planner_ai_used: planner_ai_used,
        vision_ai_used: classification.vision_ai_used,
        vision_failed: classification.vision_failed
      ).except(:description)
    end

    def persist_hits(this_case, hits)
      hits.uniq { |hit| hit[:image_url] }.filter_map do |attrs|
        record = this_case.photo_candidates.find_or_initialize_by(
          image_url: attrs[:image_url]
        )
        next record unless record.new_record? || record.pending?

        record.assign_attributes(attrs)
        record.save!
        record
      end
    end

    def build_result(records, planner_ai_used, decorated)
      vision_ai_used_count = decorated.count { |hit| hit[:vision_ai_used] }
      vision_failed_count = decorated.count { |hit| hit[:vision_failed] }

      Result.new(
        records: records,
        planner_ai_used: planner_ai_used,
        vision_ai_used_count: vision_ai_used_count,
        vision_failed_count: vision_failed_count,
        warnings: search_warnings(planner_ai_used, vision_ai_used_count, vision_failed_count, records)
      )
    end

    def search_warnings(planner_ai_used, vision_ai_used_count, vision_failed_count, records)
      warnings = []
      if AiConfig.require_ai? && !planner_ai_used
        warnings << 'Planner AI did not run on this search.'
      end
      if AiConfig.require_ai? && records.any? && vision_ai_used_count.zero?
        warnings << 'Vision AI did not verify any candidates.'
      end
      if vision_failed_count.positive?
        warnings << "#{vision_failed_count} candidate(s) had vision API failures."
      end
      warnings
    end
  end
end
