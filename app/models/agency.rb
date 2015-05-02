class Agency < ActiveRecord::Base
  has_many :articles
  belongs_to :state
end
