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
      cases_on_date_and_state.each do |case_record|
        scorer = build_scorer(case_record)
        return [case_record, scorer] if scorer.auto_accept?
      end
      nil
    end

    def pending_review_pairs
      cases_on_date_and_state.filter_map do |case_record|
        scorer = build_scorer(case_record)
        [case_record, scorer] if scorer.review?
      end
    end

    def cases_on_date_and_state
      Case.includes(:state).select do |case_record|
        case_record.date == row.date && case_record.state&.ansi_code == row.state_code
      end
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
