# frozen_string_literal: true

module FriendlyPhotos
  # Batch entry point used by the rake task and agent routine.
  class BatchSearch
    include Service

    def call(scope: nil)
      cases = scope || default_scope
      cases.map do |this_case|
        candidates = CandidateSearch.call(this_case: this_case).records
        payload(this_case, candidates)
      end
    end

    def self.summary_line(row)
      friendly = row[:candidates].count { |candidate| !candidate[:likely_mugshot] }
      "#{row[:slug]} (#{row[:subject_name]}): #{row[:candidates].size} images, " \
        "#{friendly} friendly"
    end

    private

    def default_scope
      if ENV['CASE'].present?
        identifier = ENV.fetch('CASE')
        Case.where(id: identifier).or(Case.where(slug: identifier))
      else
        Case.needing_friendly_photo.limit(ENV.fetch('LIMIT', 20).to_i)
      end
    end

    def payload(this_case, candidates)
      {
        case_id: this_case.id,
        slug: this_case.slug,
        title: this_case.title,
        subject_name: this_case.subject_display_name,
        avatar_kind: this_case.avatar_kind,
        candidates: candidates.map { |candidate| candidate_payload(candidate) }
      }
    end

    def candidate_payload(candidate)
      {
        title: candidate.title,
        image_url: candidate.image_url,
        page_url: candidate.page_url,
        license: candidate.license,
        license_url: candidate.license_url,
        likely_mugshot: candidate.likely_mugshot?,
        score: candidate.score,
        status: candidate.status
      }
    end
  end
end
