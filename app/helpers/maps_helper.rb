# frozen_string_literal: true

# Fetches the cases using Redis cache
module MapsHelper
  def fetch_cases
    cases = $redis.get('cases')

    if cases.blank?
      cases = Case.all.select do |this_case|
        this_case.latitude.present? && this_case.longitude.present?
      end.map { | case_location | [case_location.latitude, case_location.longitude] }.json

      $redis.set('cases', cases)
      $redis.expire('cases', 2.hour.to_i)
    end
    JSON.load(cases)
  end
end
