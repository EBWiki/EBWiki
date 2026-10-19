# frozen_string_literal: true

module ActiveStorageBackfill
  # Copies each Case's CarrierWave avatar original into Active Storage +photo+.
  # Read paths still use +avatar+; safe to re-run (skips cases that already have +photo+ attached).
  class CasePhotos
    include Service

    COUNTS = %i[
      scanned
      attached
      skipped_already_attached
      skipped_blank
      missing_file
      errors
    ].freeze

    def self.call(dry_run: false, limit: nil)
      new(dry_run: dry_run, limit: limit).call
    end

    def self.summary_line(counts)
      COUNTS.map { |key| "#{key}=#{counts[key]}" }.join(' ')
    end

    def initialize(dry_run: false, limit: nil)
      @dry_run = dry_run
      @limit = limit&.to_i
    end

    def call
      counts = COUNTS.index_with { 0 }

      relation = Case.order(:id)
      relation = relation.limit(@limit) if @limit&.positive?

      relation.find_each do |case_record|
        counts[:scanned] += 1
        process_case(case_record, counts)
      end

      log_summary(counts)
      counts
    end

    private

    def process_case(case_record, counts)
      return skip_blank!(counts) if case_record.read_attribute(:avatar).blank?

      source = source_file(case_record)
      return skip_missing!(case_record, counts) unless source

      return skip_already_attached!(counts) if case_record.photo.attached?

      return if @dry_run

      attach_photo(case_record, source, counts)
    rescue StandardError => e
      counts[:errors] += 1
      log_error(case_record, e)
    end

    def skip_blank!(counts)
      counts[:skipped_blank] += 1
    end

    def skip_missing!(case_record, counts)
      counts[:missing_file] += 1
      log_missing(case_record)
    end

    def skip_already_attached!(counts)
      counts[:skipped_already_attached] += 1
    end

    def attach_photo(case_record, source, counts)
      case_record.photo.attach(
        io: StringIO.new(source[:bytes]),
        filename: source[:filename],
        content_type: source[:content_type]
      )
      counts[:attached] += 1
    end

    def source_file(case_record)
      file = case_record.avatar.file
      return nil unless file&.exists?

      filename = file.filename.presence || File.basename(case_record.read_attribute(:avatar).to_s)

      {
        bytes: file.read,
        filename: filename,
        content_type: file.content_type.presence || Marcel::MimeType.for(name: filename)
      }
    rescue Excon::Error
      nil
    end

    def log_error(case_record, error)
      Rails.logger.error(
        '[active_storage:backfill_case_photos] ' \
        "case_id=#{case_record.id} error=#{error.class}: #{error.message}"
      )
    end

    def log_missing(case_record)
      Rails.logger.warn(
        '[active_storage:backfill_case_photos] ' \
        "case_id=#{case_record.id} missing CarrierWave avatar file"
      )
    end

    def log_summary(counts)
      line = self.class.summary_line(counts)
      Rails.logger.info("[active_storage:backfill_case_photos] #{line}")
    end
  end
end
