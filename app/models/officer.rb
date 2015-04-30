class Officer < ActiveRecord::Base
	has_many :article_officers
	has_many :articles, through: :article_officers

# Avatar uploader using carrierwave
	mount_uploader :avatar, AvatarUploader
	validate :required_info

	def full_name
		"#{title} #{first_name} #{last_name}"
	end

private

	def required_info
	    if( first_name.nil? )
	      errors.add(:base, "The officer's first name can't be blank.")
	    end
	    if( last_name.nil? )
	      errors.add(:base, "The officer's last name can't be blank.")
	    end
	    if( title.nil? )
	      errors.add(:base, "Please add a title.")
	    end
    end

end
