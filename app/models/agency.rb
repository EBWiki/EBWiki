# frozen_string_literal: true

class Agency < ActiveRecord::Base
  class Jurisdiction
    include EnumeratedType

    declare :none
    declare :state
    declare :local
    declare :federal
    declare :university
    declare :private
  end

  has_many :article_agencies
  has_many :articles, through: :article_agencies
  belongs_to :state

  validates :name, presence: { message: 'Please enter a name.' }
  validates :name, uniqueness: { message: 'An agency with this name already exists and can be found. If you want to create a new agency, it must have a unique name.' }
  validates :state_id, presence: { message: 'You must specify the state in which the incident occurred.' }

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  scope :by_state, ->(state_id) { where(state_id: state_id) }
  scope :by_jurisdiction, ->(jrdsn) { where(jurisdiction: jrdsn) }

  # Geocoding
  geocoded_by :full_address
  before_save :geocode, if: proc { |agcy|
    agcy.street_address_changed? || agcy.city_changed? || agcy.state_id_changed? || agcy.zipcode_changed?
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
end
