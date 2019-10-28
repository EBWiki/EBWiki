# frozen_string_literal: true

class Organization < ApplicationRecord
  def location
    Location.new(location_state, location_street_location, location_city, location_zipcode)
  end

  def location=(_location)
    location_state = state
    location_street_location = street_location
    location_city = city
    location_zipcode = zipcode
  end
end
