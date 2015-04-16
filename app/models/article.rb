class Article < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_many :links
	accepts_nested_attributes_for :links, :reject_if => :all_blank, :allow_destroy => true
	has_paper_trail
	extend FriendlyId
	friendly_id :title, use: [:slugged, :finders]
	searchkick
	
	validate :required_info
	before_save :save_state_name
# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader

	def save_state_name
		self.state = State.find(self.state_id).name
	end
private

	def required_info
	    if( state_id.nil? ) 
	      errors.add(:base, "Please specify the state where this incident occurred before saving.")
	    end
    end
end
