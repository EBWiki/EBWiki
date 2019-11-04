# frozen_string_literal: true

class Organization < ApplicationRecord
  def location
    Location.new(location_state, location_street_location, location_city, location_zipcode)
  end

  def location=(_location)
    location_state = self.state
    location_street_location = self.street_location
    location_city = self.city
    location_zipcode = self.zipcode
  end
end
