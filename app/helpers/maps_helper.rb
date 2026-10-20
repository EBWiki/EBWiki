# frozen_string_literal: true

# Fetches the cases using Redis cache
module MapsHelper
  def fetch_cases
    Rails.cache.fetch('case_locations', expires_in: 12.hours) do
      location_data(Case.with_location)
    end
  end

  def public_case_points
    Rails.cache.fetch('public_case_points', expires_in: 12.hours) do
      Maps::PublicCasePoints.call
    end
  end

  private

  def location_data(cases)
    cases.map do |case_location|
      [case_location.latitude, case_location.longitude]
    end.flatten.to_json
  end
end
