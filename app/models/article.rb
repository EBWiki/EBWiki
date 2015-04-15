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
	
# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader
end
