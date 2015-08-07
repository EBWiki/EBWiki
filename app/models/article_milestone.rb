class ArticleMilestone < ActiveRecord::Base
	has_one :milestone
	belongs_to :article
	validates :date, presence: { message: "Please add a date." }
end
