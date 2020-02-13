# frozen_string_literal: true

# Value object - date range
class Location
  attr_reader :state, :street_location, :city, :zipcode

  def initialize(state:, street_location: nil, city: nil, zipcode: nil)
    @state = state
    @street_location = street_location
    @city = city
    @zipcode = zipcode
  end

  def to_s(letter_style: false)
    if letter_style
      "#{street_location}\n#{city}, #{state} #{zipcode}"
    else
      [street_location, city, state, zipcode].compact.join(", ")
    end
  end

  # rubocop:disable Style/RedundantSelf
  def ==(other)
    state == other.state && street_location == other.street_location && city == other.city && zipcode == other.zipcode
  end
  # rubocop:enable Style/RedundantSelf
end
