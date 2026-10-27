# frozen_string_literal: true

require_relative 'text_fragments'

module PhotoFinder
  # Requires the person's name (and optionally city or state) to appear in source text.
  module ContextMatcher
    MIN_NAME_TOKEN_LENGTH = 3

    module_function

    def matches?(candidate, case_record)
      text = candidate.context_text.downcase
      name_tokens = significant_name_tokens(case_record)
      return false if name_tokens.empty?
      return false unless TextFragments.haystack_includes_any?(text, name_tokens)

      location_match?(text, case_record)
    end

    def significant_name_tokens(case_record)
      tokens = case_record.subjects.flat_map do |subject|
        subject.name.to_s.downcase.split(/\s+/)
      end.uniq
      tokens.select { |token| token.length >= MIN_NAME_TOKEN_LENGTH }
    end
    private_class_method :significant_name_tokens

    def location_match?(text, case_record)
      location_tokens = location_tokens_for(case_record)
      return true if location_tokens.empty?

      TextFragments.haystack_includes_any?(text, location_tokens)
    end
    private_class_method :location_match?

    def location_tokens_for(case_record)
      city = case_record.city.to_s.downcase.strip
      state_name = case_record.state&.name.to_s.downcase.strip
      year = case_record.date&.year&.to_s
      [city, state_name, year].compact_blank
    end
    private_class_method :location_tokens_for
  end
end
