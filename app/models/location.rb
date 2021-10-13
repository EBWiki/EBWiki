# frozen_string_literal: true

# Value object - date range
class Location < ValueObject
  attr_accessor :state, :street_location, :city, :zipcode

  def initialize(state:, street_location: nil, city: nil, zipcode: nil) # rubocop:disable Lint/MissingSuper
    @state = state
    @street_location = street_location
    @city = city
    @zipcode = zipcode
  end

  def to_s(letter_style: false)
    if letter_style
      "#{street_location}\n#{city}, #{state} #{zipcode}"
    else
      [street_location, city, state, zipcode].compact.join(', ')
    end
  end
end
