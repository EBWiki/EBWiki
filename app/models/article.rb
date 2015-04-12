class Article < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	has_paper_trail
	
# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader
end
