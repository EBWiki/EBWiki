# frozen_string_literal: true

module FriendlyPhotos
  # Finds non-mugshot Wikimedia and Openverse portraits for a case subject.
  class CandidateSearch
    include Service

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
      hits = subject_names(this_case).flat_map do |name|
        search_for(name, this_case)
      end
      records = persist ? persist_hits(this_case, hits) : []
      persist ? records : hits
    end

    private

    attr_reader :client, :openverse, :planner

    def subject_names(this_case)
      names = this_case.subjects.reload.filter_map { |subject| subject.name.presence }
      names << this_case.title if names.empty?
      names.uniq
    end

    def search_for(name, this_case)
      plan = planner.call(
        name: name,
        city: this_case.city,
        year: this_case.date&.year
      )
      plan.queries.flat_map do |query|
        combined_hits(query).filter_map { |hit| decorate(hit, name, plan.ai_used) }
      end
    end

    def combined_hits(query)
      (client.search(query: query) + openverse.search(query: query))
        .uniq(&:image_url)
        .reject { |hit| SourcePolicy.excluded_hit?(hit) }
    end

    def decorate(hit, name, planner_ai_used)
      classification = CandidateClassifier.call(hit: hit)
      hit_to_attrs(hit, name, classification, planner_ai_used)
    end

    def hit_to_attrs(hit, name, classification, planner_ai_used)
      notes = classification.reasons.join(', ').presence
      notes = [notes, 'AI planner'].compact.join('; ') if planner_ai_used
      notes = [notes, 'AI vision'].compact.join('; ') if classification.ai_used

      hit.to_h.merge(
        subject_name: name,
        likely_mugshot: classification.likely_mugshot,
        score: classification.score,
        notes: notes
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
  end
end
