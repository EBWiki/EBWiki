# frozen_string_literal: true

require_relative 'match_scorer'
require_relative 'match_context'

module MpvPhotoImport
  class CaseMatcher
    def initialize(row)
      @row = row
    end

    def best_case_match
      auto_accept_pair || best_pending_review_pair
    end

    private

    attr_reader :row

    def auto_accept_pair
      candidate_cases.each do |case_record|
        scorer = build_scorer(case_record)
        return [case_record, scorer] if scorer.auto_accept?
      end
      nil
    end

    def pending_review_pairs
      candidate_cases.filter_map do |case_record|
        scorer = build_scorer(case_record)
        [case_record, scorer] if scorer.review?
      end
    end

    def best_pending_review_pair
      pending_review_pairs.min_by { |case_record, scorer| review_sort_key(case_record, scorer) }
    end

    def review_sort_key(case_record, scorer)
      detail = scorer.match_detail
      exact_matches = [detail[:exact_name], detail[:exact_date], detail[:exact_state]].count(true)

      [
        -exact_matches,
        detail[:exact_state] ? 0 : 1,
        date_gap_days(case_record),
        case_record.id
      ]
    end

    def date_gap_days(case_record)
      return Float::INFINITY unless row.date.present? && case_record.date.present?

      (row.date - case_record.date).abs.to_i
    end

    def candidate_cases
      @candidate_cases ||= Case.includes(:state)
                               .left_joins(:state)
                               .where('cases.date = :date OR states.ansi_code = :state_code',
                                      date: row.date, state_code: row.state_code)
    end

    def build_scorer(case_record)
      context = MatchContext.new(
        mpv_name: row.name,
        mpv_date: row.date,
        mpv_state_code: row.state_code,
        case_title: case_record.title,
        case_date: case_record.date,
        case_state_code: case_record.state&.ansi_code
      )
      MatchScorer.new(context)
    end
  end
end
