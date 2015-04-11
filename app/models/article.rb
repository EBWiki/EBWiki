class Article < ActiveRecord::Base
	belongs_to :user
	belongs_to :category
	
# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader
end
