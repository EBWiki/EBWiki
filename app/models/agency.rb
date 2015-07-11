class Agency < ActiveRecord::Base
  has_many :articles
  belongs_to :state

  geocoded_by :full_address   # can also be an IP address
	after_validation :geocode          # auto-fetch coordinates

	def full_address
		"#{address} #{city} #{state} #{zipcode}"
	end
end
