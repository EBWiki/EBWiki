# frozen_string_literal: true

require 'csv'

require_relative 'row'
require_relative 'report'
require_relative 'row_processor'

module MpvPhotoImport
  # Reads Mapping Police Violence CSV data and links credited photo URLs to cases.
  #
  # Auto-accept requires exact normalized name, exact date of death, and the same state.
  # Near matches are stored in +case_mpv_photo_reviews+ for human confirmation.
  # Mugshot and booking-site URLs are rejected using the same rules as PhotoFinder.
  class Importer
    def initialize(csv_path:, logger: Rails.logger)
      @csv_path = csv_path
      @logger = logger
    end

    def call
      report = Report.new
      logger.info('[MpvPhotoImport] starting import')

      each_row { |row| import_row(row, report) }

      logger.info("[MpvPhotoImport] finished #{report.to_h}")
      report
    end

    private

    attr_reader :csv_path, :logger

    def import_row(row, report)
      RowProcessor.new(report: report, logger: logger).call(row)
    rescue StandardError => e
      message = "line #{row.line_number}: #{e.class}: #{e.message}"
      report.record_error(message)
      ErrorReporter.report(e, mpv_import_line: row.line_number)
      logger.error("[MpvPhotoImport] #{message}")
    end

    def each_row
      CSV.foreach(csv_path, headers: true, encoding: 'bom|utf-8').with_index(2) do |raw, line|
        yield Row.new(line_number: line, raw: raw.to_h)
      end
    end
  end
end
