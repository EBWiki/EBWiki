# frozen_string_literal: true

# This module contains a number of methods to calculate various statistics
module Statistics
  def self.mom_changed_cases_growth(cases_at_start:, cases_at_end:)
    return 0 if cases_at_end.size.zero?

    case_growth = cases_at_start.size - cases_at_end.size
    return (cases_at_end.size * 100) if case_growth.zero?

    (((cases_at_end.size.to_f / case_growth) - 1) * 100).round(2)
  end

  # rubocop:disable Metrics/AbcSize
  def self.mom_cases_growth(cases_at_start:, cases_at_end:)
    return 0 if cases_at_end.size.zero?

    case_growth = cases_at_start.size - cases_at_end.size
    return (cases_at_end.size * 100) if case_growth.zero?

    (cases_at_end.size.to_f / (cases_at_start.size - cases_at_end.size) * 100).round(2)
  end
  # rubocop:enable Metrics/AbcSize
end
