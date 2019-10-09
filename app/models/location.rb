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

  def to_s
    [street_location, city, state, ("Zipcode: #{zipcode}" if zipcode)].compact.join(", ")
  end

  def ==(object)
    object.class.eql?(self.class) && self.to_s.eql?(object.to_s)
  end
end
