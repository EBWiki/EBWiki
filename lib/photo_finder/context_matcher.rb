# frozen_string_literal: true

module PhotoFinder
  # Requires the person's name (and optionally city or state) to appear in source text.
  module ContextMatcher
    MIN_NAME_TOKEN_LENGTH = 3

    module_function

    def matches?(candidate, case_record)
      text = candidate.context_text.downcase
      name_tokens = significant_name_tokens(case_record)
      return false if name_tokens.empty?

      name_match = name_tokens.any? { |token| text.include?(token) }
      return false unless name_match

      location_match?(text, case_record)
    end

    def significant_name_tokens(case_record)
      case_record.subjects.flat_map do |subject|
        subject.name.to_s.downcase.split(/\s+/)
      end.uniq.select { |token| token.length >= MIN_NAME_TOKEN_LENGTH }
    end
    private_class_method :significant_name_tokens

    def location_match?(text, case_record)
      city = case_record.city.to_s.downcase.strip
      state_name = case_record.state&.name.to_s.downcase.strip

      year = case_record.date&.year&.to_s
      location_tokens = [city, state_name, year].reject(&:blank?)
      return true if location_tokens.empty?

      location_tokens.any? { |token| text.include?(token) }
    end
    private_class_method :location_match?
  end
end
