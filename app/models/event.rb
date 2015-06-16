class Event < ActiveRecord::Base
	belongs_to :article

	validates :article_id, presence: { message: "An event must belong to an Article." }
	validates :date, presence: { message: "Please add a date." }
	validates :title, presence:  { message: "Title (name of the victim) can't be blank." }
	validates :title, uniqueness:  { scope: :article, message: "We already have an article with this victim" }
end
