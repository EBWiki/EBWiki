class Agency < ActiveRecord::Base
  has_many :article_agencies
  has_many :articles, through: :article_agencies
  belongs_to :state
  validates :name, uniqueness: { message: "We already have an article with this victim" }
  validates :state_id, presence: { message: "Please specify the state where this agency has headquarters." }

  geocoded_by :full_address   # can also be an IP address
	after_validation :geocode          # auto-fetch coordinates

	extend FriendlyId
	friendly_id :name, use: [:slugged, :finders]

	def full_address
		"#{address} #{city} #{state} #{zipcode}"
	end
end
