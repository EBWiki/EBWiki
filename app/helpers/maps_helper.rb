# frozen_string_literal: true

# Fetches the cases using Redis cache
# rubocop:disable Metrics/AbcSize
module MapsHelper
  def fetch_cases
    cases = $redis.get('cases')

    if cases.blank?
      cases = Case.all.select do |this_case|
        this_case.latitude.present? && this_case.longitude.present?
      end
      cases = cases.map { |case_location| [case_location.latitude, case_location.longitude] }.to_json

      $redis.set('cases', cases)
      $redis.expire('cases', 2.hour.to_i)
    end
    JSON.load(cases)
  end
  # rubocop:enable Metrics/AbcSize
end
