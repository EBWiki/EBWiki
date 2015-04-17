class Officer < ActiveRecord::Base
	has_many :article_officers
	has_many :articles, through: :article_officers
	
# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader

	def full_name
		"#{title} #{first_name} #{last_name}"
	end

end
