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
      planner_ai_used, raw_hits = collect_hits(this_case)
      AiConfig.enforce_planner!(planner_ai_used)
      decorated = HitDecorator.call(
        raw_hits: raw_hits,
        this_case: this_case,
        planner_ai_used: planner_ai_used
      )
      records = persist ? persist_hits(this_case, decorated) : []
      SearchOutcome.call(records: records, planner_ai_used: planner_ai_used, decorated: decorated)
    end

    private

    attr_reader :client, :openverse, :planner

    def collect_hits(this_case)
      planner_ai_used = false
      raw_hits = []
      subject_names(this_case).each do |name|
        plan = plan_for(name, this_case)
        planner_ai_used ||= plan.ai_used
        plan.queries.each { |query| raw_hits.concat(combined_hits(query)) }
      end
      [planner_ai_used, raw_hits]
    end

    def plan_for(name, this_case)
      planner.call(
        name: name,
        city: this_case.city,
        year: this_case.date&.year,
        slug: this_case.slug
      )
    end

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

    def persist_hits(this_case, hits)
      hits.uniq { |hit| hit[:image_url] }.filter_map do |attrs|
        upsert_candidate(this_case, attrs)
      end
    end

    def upsert_candidate(this_case, attrs)
      record = this_case.photo_candidates.find_or_initialize_by(image_url: attrs[:image_url])
      return record unless record.new_record? || record.pending?

      record.assign_attributes(attrs)
      record.save!
      record
    rescue ActiveRecord::RecordNotUnique
      this_case.photo_candidates.find_by!(image_url: attrs[:image_url])
    end
  end
end
