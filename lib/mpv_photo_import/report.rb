# frozen_string_literal: true

module MpvPhotoImport
  # Counts and messages produced by an import run.
  class Report
    attr_reader :auto_matched, :review_queue, :rejected, :skipped, :errors

    def initialize
      @auto_matched = 0
      @review_queue = 0
      @rejected = 0
      @skipped = 0
      @errors = []
    end

    def record_auto_match!
      @auto_matched += 1
    end

    def record_review!
      @review_queue += 1
    end

    def record_rejected!
      @rejected += 1
    end

    def record_skipped!
      @skipped += 1
    end

    def record_error(message)
      @errors << message
    end

    def to_h
      {
        auto_matched: auto_matched,
        review_queue: review_queue,
        rejected: rejected,
        skipped: skipped,
        error_count: errors.size
      }
    end

    def summary
      to_h.merge(errors: errors)
    end
  end
end
