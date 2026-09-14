# frozen_string_literal: true

# Fetches geocoded cases for the case map
module MapsHelper
  CASE_MAP_CACHE_KEY = 'case_map_locations_v2'
  CASE_MAP_CACHE_TTL = 12.hours

  def fetch_cases
    Rails.cache.fetch(CASE_MAP_CACHE_KEY, expires_in: CASE_MAP_CACHE_TTL) do
      location_data(Case.with_location.select(:id, :latitude, :longitude, :title, :slug, :city))
    end
  end

  def case_has_location?(this_case)
    this_case.latitude.present? && this_case.longitude.present?
  end

  private

  def location_data(cases)
    cases.map do |case_location|
      {
        lat: case_location.latitude,
        lng: case_location.longitude,
        title: case_location.title,
        slug: case_location.slug,
        city: case_location.city,
        url: case_path(case_location)
      }
    end
  end
end
