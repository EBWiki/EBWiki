# frozen_string_literal: true

module FriendlyPhotos
  # Finds non-mugshot Wikimedia portraits for people documented on a case.
  class CandidateSearch
    include Service

    def initialize(client: WikimediaClient.new)
      @client = client
    end

    def call(this_case:, persist: true)
      hits = subject_names(this_case).flat_map do |name|
        search_for(name, this_case)
      end
      records = persist ? persist_hits(this_case, hits) : []
      persist ? records : hits
    end

    private

    attr_reader :client

    def subject_names(this_case)
      names = this_case.subjects.filter_map { |subject| subject.name.presence }
      names << this_case.title if names.empty?
      names.uniq
    end

    def search_for(name, this_case)
      queries_for(name, this_case).flat_map do |query|
        client.search(query: query).map { |hit| decorate(hit, name) }
      end
    end

    def queries_for(name, this_case)
      [
        name,
        [name, this_case.city].compact.join(' '),
        "#{name} portrait"
      ].uniq
    end

    def decorate(hit, name)
      classification = MugshotClassifier.call(
        text: [hit.title, hit.description, hit.image_url, hit.page_url]
      )
      hit_to_attrs(hit, name, classification)
    end

    def hit_to_attrs(hit, name, classification)
      hit.to_h.merge(
        subject_name: name,
        likely_mugshot: classification.likely_mugshot,
        score: classification.score,
        notes: classification.reasons.join(', ').presence
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
