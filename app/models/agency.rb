# frozen_string_literal: true

# This model refers to law enforcement agencies involved in the cases
class Agency < ApplicationRecord
  # This is the jurisdiction of the agency
  enum jurisdiction: {
    unknown: 'unknown',
    local: 'local',
    state: 'state',
    federal: 'federal',
    university: 'university',
    commercial: 'commercial'
  }.freeze

  STRIPPED_ATTRIBUTES = %w[
    name
    city
    street_address
    zipcode
    telephone
    email
    website
  ].freeze

  auto_strip_attributes(*STRIPPED_ATTRIBUTES)

  has_paper_trail
  has_many :case_agencies
  has_many :cases, through: :case_agencies
  belongs_to :state

  validates :name, presence: { message: 'Please enter a name.' }
  validates :name, uniqueness: {
    message: 'An agency with this name already exists and can be found. If you'\
             ' want to create a new agency, it must have a unique name.'
  }
  validates :state_id, presence: {
    message: 'You must specify the state in which the agency is located.'
  }

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  # Geocoding
  geocoded_by :full_address
  before_save :geocode, if: proc { |agcy|
    agcy.street_address_changed? ||
      agcy.city_changed? ||
      agcy.state_id_changed? ||
      agcy.zipcode_changed?
  } # auto-fetch coordinates

  def full_address
    "#{street_address} #{city} #{state.ansi_code} #{zipcode}".strip
  end

  def nearby_cases
    try(:nearbys, 50).try(:order, 'distance')
  end

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :name,
      %i[name city],
      %i[name street_address city]
    ]
  end

  def retrieve_state
    State.where(id: state_id).pluck(:name).join
  end

  def location
    @location ||= Location.new(
      state: state.name,
      street_location: street_address,
      city: city,
      zipcode: zipcode
    )
  end

  def location=(location)
    self.state = State.find_by_name(location.state)
    self.street_address = location.street_location
    self.city = location.city
    self.zipcode = location.zipcode
  end
end
