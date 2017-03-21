class ArticleMilestone < ActiveRecord::Base
  belongs_to :article
  belongs_to :milestone

  validates :milestone_id, presence: { message: 'please specify a milestone'}
  validates :date_occurred, presence: { message: 'please specify a date when the milestone occurred'}
end
