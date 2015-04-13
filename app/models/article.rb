class Article < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged
  belongs_to :user
  belongs_to :category
  has_paper_trail
	
# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader
end
