class State < ActiveRecord::Base
	has_many :articles
	searchkick
end
