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

      def search(query:, page: 1, state_id: nil)
        rel = cases.combine(:us_state, :subjects)
        rel = rel.where(state_id: Integer(state_id)) if state_id.to_s.match?(/\A\d+\z/)

        q = query.to_s.strip
        rel = apply_search(rel, q) unless q.empty?

        rel.order(cases[:date].desc)
          .page([page.to_i, 1].max)
          .per_page(PAGE_SIZE)
          .to_a
      end

      def search_count(query:, state_id: nil)
        rel = cases
        rel = rel.where(state_id: Integer(state_id)) if state_id.to_s.match?(/\A\d+\z/)
        q = query.to_s.strip
        rel = apply_search(rel, q) unless q.empty?
        rel.count
      end

      def history_for(slug)
        record = cases.where(slug: slug).one
        return unless record

        versions = self.versions
          .where(item_type: "Case", item_id: record.id)
          .order(self.versions[:created_at].desc)
          .to_a

        {record: record, versions: versions}
      end

      private

      def agencies_for(case_id)
        agency_ids = case_agencies.where(case_id: case_id).to_a.map(&:agency_id)
        return [] if agency_ids.empty?

        agencies.where(id: agency_ids).to_a
      end

      def apply_search(rel, query)
        if cases.dataset.columns.include?(:tsv)
          rel.where(Sequel.lit("tsv @@ plainto_tsquery('english', ?)", query))
        else
          pattern = "%#{self.class.escape_like(query)}%"
          rel.where(
            Sequel.lit(
              "title ILIKE ? OR city ILIKE ? OR overview ILIKE ? OR COALESCE(blurb, '') ILIKE ?",
              pattern, pattern, pattern, pattern
            )
          )
        end
      end

      def self.escape_like(value)
        value.gsub(/[%_\\]/) { |char| "\\#{char}" }
      end
    end
  end
end
