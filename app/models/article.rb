class Article < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	belongs_to :state
	belongs_to :agency
	has_many :links
	accepts_nested_attributes_for :links, :reject_if => :all_blank, :allow_destroy => true
	has_many :article_officers
	has_many :officers, through: :article_officers
	accepts_nested_attributes_for :officers, :reject_if => :all_blank, :allow_destroy => true
	has_paper_trail
	acts_as_followable
	extend FriendlyId
	friendly_id :title, use: [:slugged, :finders]
	searchkick

	validates :state_id, presence: { message: "Please specify the state where this incident occurred before saving." }
	validates :date, presence: { message: "Please add a date." }
	validates :title, presence:  { message: "Title (name of the victim) can't be blank." }
	validates :title, uniqueness: { message: "We already have an article with this victim" }
# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader

	geocoded_by :full_address   # can also be an IP address
	after_validation :geocode          # auto-fetch coordinates

	def full_address
		"#{address} #{city} #{state}"
	end

	def self.find_by_search(query)
	    search(query)
	end
private

end
