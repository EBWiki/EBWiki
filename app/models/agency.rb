class Agency < ActiveRecord::Base
  has_many :article_agencies
  has_many :articles, through: :article_agencies
  belongs_to :state

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :state_id, presence: true

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  
  scope :by_state, -> (state_id) {where(state_id: state_id)}
  
  # Geocoding
  geocoded_by :full_address
  before_save :geocode, if: Proc.new {|agcy| 
    agcy.street_address_changed? || agcy.city_changed? || agcy.state_id_changed? || agcy.zipcode_changed?
  } # auto-fetch coordinates
  
  def full_address
    "#{street_address} #{city} #{state.ansi_code} #{zipcode}".strip
  end
  
  def nearby_cases
    self.try(:nearbys, 50).try(:order, "distance")
  end

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :name,
      [:name, :city],
      [:name, :street_address, :city],
    ]
  end
end
