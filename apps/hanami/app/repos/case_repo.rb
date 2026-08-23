# frozen_string_literal: true

module EbWiki
  module Repos
    class CaseRepo < EbWiki::DB::Repo
      PAGE_SIZE = 12
      RECENT_LIMIT = 10

      def homepage(page: 1)
        page_number = [page.to_i, 1].max

        cases
          .combine(:us_state, :subjects)
          .order(cases[:date].desc)
          .page(page_number)
          .per_page(PAGE_SIZE)
          .to_a
      end

      def recently_updated(limit: RECENT_LIMIT)
        cases.order(cases[:updated_at].desc).limit(limit).to_a
      end

      def total_count
        cases.count
      end

      def find_page(slug)
        record = cases.where(slug: slug).one
        return unless record

        {
          record: record,
          state: record.state_id && states.where(id: record.state_id).one,
          subjects: subjects.where(case_id: record.id).to_a,
          agencies: agencies_for(record.id),
          links: links
            .where(linkable_type: "Case", linkable_id: record.id)
            .order(links[:created_at].desc)
            .to_a
        }
      end

      def exists_slug?(slug)
        !cases.where(slug: slug).one.nil?
      end

      private

      def agencies_for(case_id)
        agency_ids = case_agencies.where(case_id: case_id).to_a.map(&:agency_id)
        return [] if agency_ids.empty?

        agencies.where(id: agency_ids).to_a
      end
    end
  end
end
