# frozen_string_literal: true

require 'did_you_mean/levenshtein'

require_relative 'name_normalizer'
require_relative 'match_context'

module MpvPhotoImport
  # Scores a Mapping Police Violence row against an EBWiki case for import routing.
  class MatchScorer
    NEAR_NAME_DISTANCE = 2

    def initialize(context)
      @context = context
    end

    def auto_accept?
      exact_name? && exact_date? && exact_state?
    end

    def review?
      return false if auto_accept?

      near_name_on_date_and_state? || two_exact_fields_with_third_off?
    end

    def exact_name?
      normalized_mpv_name == normalized_case_name
    end

    def exact_date?
      context.mpv_date.present? &&
        context.case_date.present? &&
        context.mpv_date == context.case_date
    end

    def exact_state?
      context.mpv_state_code.present? && context.case_state_code.present? &&
        context.mpv_state_code.to_s.upcase == context.case_state_code.to_s.upcase
    end

    def near_name?
      return false if normalized_mpv_name.blank? || normalized_case_name.blank?
      return true if normalized_mpv_name == normalized_case_name

      distance = DidYouMean::Levenshtein.distance(normalized_mpv_name, normalized_case_name)
      distance <= NEAR_NAME_DISTANCE
    end

    def match_detail
      {
        exact_name: exact_name?,
        exact_date: exact_date?,
        exact_state: exact_state?,
        near_name: near_name?
      }
    end

    private

    attr_reader :context

    def near_name_on_date_and_state?
      exact_date? && exact_state? && near_name? && !exact_name?
    end

    def two_exact_fields_with_third_off?
      (exact_name? && exact_state? && !exact_date?) ||
        (exact_name? && exact_date? && !exact_state?)
    end

    def normalized_mpv_name
      @normalized_mpv_name ||= NameNormalizer.normalize(context.mpv_name)
    end

    def normalized_case_name
      @normalized_case_name ||= NameNormalizer.normalize(context.case_title)
    end
  end
end
