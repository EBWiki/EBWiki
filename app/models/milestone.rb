class Milestone < ActiveRecord::Base
  has_many :article_milestones, dependent: :destroy
  has_many :articles, through: :article_milestones
end
