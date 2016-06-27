class Agency < ActiveRecord::Base
  has_many :article_agencies, dependent: :destroy
  has_many :articles, through: :article_agencies
  belongs_to :state
end
