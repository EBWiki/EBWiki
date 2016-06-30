class Agency < ActiveRecord::Base
  has_many :article_agencies
  has_many :articles, through: :article_agencies
  belongs_to :state

  validates :name, presence: true
  validates :name, uniqueness: true

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :name,
      [:name, :city],
      [:name, :street_address, :city],
    ]
  end
end
