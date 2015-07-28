class Subject < ActiveRecord::Base
	belongs_to :article
	validates :name, presence:  { message: "Name of the victim can't be blank." }
end
