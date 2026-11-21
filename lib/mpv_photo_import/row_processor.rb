# frozen_string_literal: true

require_relative 'case_matcher'
require_relative 'mugshot_url_rejector'

module MpvPhotoImport
  class RowProcessor
    PHOTO_STATUS_SHOWN = 'shown'

    def initialize(report:, logger: Rails.logger)
      @report = report
      @logger = logger
    end

    def call(row)
      return report.record_skipped! unless row.valid_for_matching?
      return report.record_rejected! if mugshot_url?(row)

      case_record, scorer = CaseMatcher.new(row).best_case_match
      return report.record_skipped! if case_record.nil?

      route_row(case_record, row, scorer)
    end

    private

    attr_reader :report, :logger

    def mugshot_url?(row)
      MugshotUrlRejector.rejected?(row.victim_image_url, source_page_url: row.photo_source_url)
    end

    def route_row(case_record, row, scorer)
      if scorer.auto_accept?
        apply_auto_match(case_record, row)
        report.record_auto_match!
      elsif scorer.review?
        enqueue_review(case_record, row, scorer)
        report.record_review!
      else
        report.record_skipped!
      end
    end

    def apply_auto_match(case_record, row)
      case_record.update!(
        photo_url: row.victim_image_url,
        photo_source_url: row.photo_source_url,
        photo_credit: row.photo_credit,
        photo_status: PHOTO_STATUS_SHOWN
      )
    end

    def enqueue_review(case_record, row, scorer)
      CaseMpvPhotoReview.create!(
        case: case_record,
        mpv_name: row.name,
        mpv_date: row.date,
        mpv_state: row.state_code,
        victim_image_url: row.victim_image_url,
        photo_source_url: row.photo_source_url,
        photo_credit: row.photo_credit,
        match_detail: scorer.match_detail.to_json
      )
    end
  end
end
