# frozen_string_literal: true

require_relative 'match_scorer'
require_relative 'match_context'

module MpvPhotoImport
  class CaseMatcher
    def initialize(row)
      @row = row
    end

    def best_case_match
      auto_accept_pair || pending_review_pairs.first
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
