# frozen_string_literal: true

# Value object - date range
class Location < ValueObject
  attr_accessor :state, :street_location, :city, :zipcode

  def initialize(attrs = {}) # rubocop:disable Lint/MissingSuper
    if attrs.is_a?(Hash)
      @state = attrs[:state] || attrs['state']
      @street_location = attrs[:street_location] || attrs['street_location']
      @city = attrs[:city] || attrs['city']
      @zipcode = attrs[:zipcode] || attrs['zipcode']
    else
      # Handle keyword arguments for backward compatibility
      @state = attrs
    end

    raise ArgumentError, 'State is required' if @state.nil?
  end

  def to_s(letter_style: false)
    if letter_style
      "#{street_location}\n#{city}, #{state} #{zipcode}"
    else
      [street_location, city, state, zipcode].compact.join(', ')
    end
  end
end
