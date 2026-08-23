# frozen_string_literal: true

module EbWiki
  module Repos
    class AgencyRepo < EbWiki::DB::Repo
      def all_ordered
        agencies.order(agencies[:name].asc).to_a
      end

      def find_page(slug)
        record = agencies.where(slug: slug).one
        return unless record

        case_ids = case_agencies.where(agency_id: record.id).to_a.map(&:case_id)
        related = if case_ids.empty?
          []
        else
          cases.combine(:us_state, :subjects).where(id: case_ids).order(cases[:date].desc).to_a
        end

        {
          record: record,
          state: record.state_id && states.where(id: record.state_id).one,
          cases: related
        }
      end
    end
  end
end
