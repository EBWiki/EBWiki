class ArticleMilestone < ActiveRecord::Base
  belongs_to :article
  belongs_to :milestone
end
