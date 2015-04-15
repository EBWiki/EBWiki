class Article < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_paper_trail
	extend FriendlyId
	friendly_id :title, use: [:slugged, :finders]
	searchkick
	
# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader
end
