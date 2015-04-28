class Article < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_many :links
	accepts_nested_attributes_for :links, :reject_if => :all_blank, :allow_destroy => true
	has_many :article_officers
	has_many :officers, through: :article_officers
	accepts_nested_attributes_for :officers, :reject_if => :all_blank, :allow_destroy => true
	has_paper_trail
	extend FriendlyId
	friendly_id :title, use: [:slugged, :finders]
	searchkick
	
	validate :required_info
	validates :title, uniqueness: { message: "We already have an article with this victim" }
	before_save :save_state_name
# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader

	geocoded_by :full_address   # can also be an IP address
	after_validation :geocode          # auto-fetch coordinates

	def full_address
		"#{address} #{city} #{state}"
	end

	def save_state_name
		self.state = State.find(self.state_id).name
	end

	def self.find_by_search(query)
	    search(query)		
	end
private

	def required_info
	    errors.add(:base, "Please specify the state where this incident occurred before saving.") if state_id.nil?
	    errors.add(:base, "Title (name of the victim) can't be blank.") if title.nil?
	    errors.add(:base, "Please add a date.") if date.nil?
    end
end
