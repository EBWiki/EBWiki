class State < ActiveRecord::Base
	has_many :articles
  has_many :agencies
	searchkick
end
