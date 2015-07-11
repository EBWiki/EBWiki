class Agency < ActiveRecord::Base
  has_many :articles
  belongs_to :state
  validates :name, uniqueness: { message: "We already have an article with this victim" }

  geocoded_by :full_address   # can also be an IP address
	after_validation :geocode          # auto-fetch coordinates

	def full_address
		"#{address} #{city} #{state} #{zipcode}"
	end
end
