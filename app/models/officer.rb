class Officer < ActiveRecord::Base
	has_many :article_officers
	has_many :articles, through: :article_officers
end
