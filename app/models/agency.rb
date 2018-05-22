# frozen_string_literal: true

# This model refers to law enforcement agencies involved in the cases
class Agency < ActiveRecord::Base
  # This is the jurisdiction of the agency
  # TODO: Determine a better way to do these enums
  class JurisdictionType
    include EnumeratedType

    declare :none
    declare :state
    declare :local
    declare :federal
    declare :university
    declare :private
  end

  has_many :case_agencies
  has_many :cases, through: :case_agencies
  belongs_to :state

  before_save do
    self.name = name.lstrip
  end

  validates :name, presence: { message: 'Please enter a name.' }
  validates :name, uniqueness: {
    message: 'An agency with this name already exists and can be found. If you'\
             ' want to create a new agency, it must have a unique name.'
  }
  validates :state_id, presence: {
    message: 'You must specify the state in which the incident occurred.'
  }
  validates :jurisdiction_type, inclusion: { 
    in: %w(none state local federal university private),
    message: 'You must enter one of the listed jurisdiction type.' 
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

end
