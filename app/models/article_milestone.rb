class ArticleMilestone < ActiveRecord::Base
	belongs_to :milestone
	belongs_to :article
	validates :date, presence: { message: "Please add a date." }
end
