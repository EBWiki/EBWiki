# This is still called "Article", although its true name is "Case"
# TODO: Rename this to Case
# 
class Article < ActiveRecord::Base
  # TODO: Clean up relationship section
  belongs_to :user
  belongs_to :category
  belongs_to :state
  has_many :article_agencies
  has_many :agencies, through: :article_agencies
  has_many :links
  accepts_nested_attributes_for :links, :reject_if => :all_blank, :allow_destroy => true
  has_many :article_officers
  has_many :officers, through: :article_officers
  accepts_nested_attributes_for :officers, :reject_if => :all_blank, :allow_destroy => true
  has_many :comments, as: :commentable
  has_many :subjects
  accepts_nested_attributes_for :subjects, :reject_if => :all_blank, :allow_destroy => true
  has_many :article_milestones
  has_many :milestones, through: :article_milestones
  accepts_nested_attributes_for :article_milestones, :reject_if => :all_blank, :allow_destroy => true

  # Paper Trail
  has_paper_trail :only => [:title, :overview, :litigation, :community_action]
  # Acts as Follows, for follower functionality
  acts_as_followable

  # Friendly ID
  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]
  
  # Elasticsearch Gem
  searchkick


  # Model Validations
  validates :date, presence: { message: "Please add a date." }
  validates :city, presence: { message: "Please add a city." }
  validates :state_id, presence: { message: "Please specify the state where this incident occurred before saving." }


  # Avatar uploader using carrierwave
  mount_uploader :avatar, AvatarUploader

  # Geocoding articles
  geocoded_by :full_address   # can also be an IP address
  after_validation :geocode          # auto-fetch coordinates


  # Scopes
  scope :by_state, -> (state_id) {where(state_id: state_id)}
  
  def full_address
    "#{address} #{city} #{state} #{zipcode}"
  end

  def self.find_by_search(query)
    search(query)
  end

  def nearby_cases
    self.try(:nearbys, 50).try(:order, "distance")
    #self.nearbys(50).order("distance")
  end

end
