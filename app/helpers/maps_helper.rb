# frozen_string_literal: true

# Fetches the cases using Redis cache
module MapsHelper
  def fetch_cases
    cases = $redis.get('cases')

    if cases.blank?
      case_locations = location_data(Case.with_location)
      $redis.set('cases', case_locations)
      $redis.expire('cases', 2.hour.to_i)
    end
    cases
  end

  private

  def location_data(cases)
    cases.map do |case_location|
      [case_location.latitude, case_location.longitude]
    end.flatten.to_json
  end
end
