# This is still called "Article", although its true name is "Case"
# TODO: Rename this to Case
#
class Article < ActiveRecord::Base
  # TODO: Clean up relationship section
  belongs_to :user
  belongs_to :category
  belongs_to :state
  has_many :links, dependent: :destroy
  accepts_nested_attributes_for :links, :reject_if => :all_blank, :allow_destroy => true
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :follows, as: :followable, dependent: :destroy
  has_many :subjects, dependent: :destroy
  accepts_nested_attributes_for :subjects, :reject_if => :all_blank, :allow_destroy => true

  has_many :article_agencies, dependent: :destroy
  has_many :agencies, through: :article_agencies
  accepts_nested_attributes_for :article_agencies, :reject_if => :all_blank, :allow_destroy => true

  has_many :article_documents, dependent: :destroy
  has_many :documents, through: :article_documents
  accepts_nested_attributes_for :article_documents, :reject_if => :all_blank, :allow_destroy => true
  # Paper Trail
  has_paper_trail :ignore => [:summary], :meta => { :comment  => :edit_summary }

  # Acts as Follows, for follower functionality
  acts_as_followable

  # Friendly ID
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  # Elasticsearch Gem
  searchkick


  # Model Validations
  validates :date, presence: { message: "Please add a date." }
  validate :article_date_cannot_be_in_the_future
  validates :city, presence: { message: "Please add a city." }
  validates :state_id, presence: { message: "Please specify the state where this incident occurred before saving." }
  validates :title, presence: { message: "Please specify a title"}
  validates_associated :subjects
  validates :subjects, presence: { message: 'at least one subject is required'}
  validates :summary, presence: { message: 'Please use the last field at the bottom of this form to summarize your edits to the article.'}

  # Avatar uploader using carrierwave
  mount_uploader :avatar, AvatarUploader

  # Geocoding articles
  geocoded_by :full_address   # can also be an IP address
  # before_validation :check_for_empty_fields
  after_validation :geocode          # auto-fetch coordinates


  # Scopes
  scope :by_state, -> (state_id) {where(state_id: state_id)}
  scope :property_count_over_time, -> (property, days) { where( "#{property}": "#{days}".to_i.days.ago..Time.now).count }

  def full_address
    "#{address} #{city} #{state} #{zipcode}"
  end

  def self.find_by_search(query)
    search(query)
  end

  def nearby_cases
    self.try(:nearbys, 50).try(:order, "distance")
  end

  def article_date_cannot_be_in_the_future
    if date.present? && date > Date.today
      errors.add(:date, "must be in the past")
    end
  end

  def edit_summary
    return summary
  end

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :title,
      [:title, :city],
      [:title, :city, :zipcode]
    ]
  end

  def mom_new_cases_growth
    last_month_cases = Article.property_count_over_time("date", 30)
    last_60_days_cases = Article.property_count_over_time("date", 60)
    prior_30_days_cases = last_60_days_cases - last_month_cases

    return (((last_month_cases.to_f / prior_30_days_cases) - 1) * 100).round(2)
  end

  def mom_cases_growth
    last_month_cases = Article.property_count_over_time("created_at", 30)

    return (last_month_cases.to_f / (Article.count-last_month_cases) * 100).round(2)
  end

  def cases_updated_last_30_days
    Article.property_count_over_time("updated_at", 30)
  end

  def mom_growth_in_case_updates
    last_month_case_updates = Article.property_count_over_time("updated_at", 30)
    last_60_days_case_updates = Article.property_count_over_time("updated_at", 60)
    prior_30_days_case_updates = last_60_days_case_updates - last_month_case_updates

    return (((last_month_case_updates.to_f / prior_30_days_case_updates) - 1) * 100).round(2)
  end

private

  def check_for_empty_fields
    attrs = ["title", "date", "address", "city", "state", "zipcode", "state_id", "avatar", "video_url", "overview", "community_action", "litigation", "country", "remove_avatar"]

    unless (self.changed & attrs).any?
      self.errors[:base] << "You must change field other than summary to generate a new version"
    end
  end
end
