class ArticleMilestone < ActiveRecord::Base
	belongs_to :milestone
	belongs_to :article
end
