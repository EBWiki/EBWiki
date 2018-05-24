# frozen_string_literal: true

# This is the main model of the application. Each death is a case.
# TODO: Lots & lots of refactoring
class Case < ActiveRecord::Base
  # TODO: Clean up relationship section
  belongs_to :user
  belongs_to :category
  belongs_to :state
  has_many :links, dependent: :destroy
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :follows, as: :followable, dependent: :destroy
  has_many :subjects, dependent: :destroy
  accepts_nested_attributes_for :subjects, reject_if: :all_blank, allow_destroy: true

  has_many :case_agencies, dependent: :destroy
  has_many :agencies, through: :case_agencies
  accepts_nested_attributes_for :case_agencies, reject_if: :all_blank, allow_destroy: true
  # Paper Trail
  has_paper_trail ignore: [:summary], meta: { comment: :edit_summary }

  # Acts as Follows, for follower functionality
  acts_as_followable

  # Friendly ID
  extend FriendlyId
  friendly_id :slug_candidates, use: %i[slugged finders]

  # Elasticsearch Gem
  searchkick _all: false, default_fields: ['*']

  # Model Validations
  validates :date, presence: { message: 'Please add a date.' }
  validate :case_date_cannot_be_in_the_future
  validates :city, presence: { message: 'Please add a city.' }
  validates :state_id, presence: {
    message: 'Please specify the state where this incident occurred before saving.'
  }
  validates :title, presence: { message: 'Please specify a title' }
  validates_associated :subjects
  validates :subjects, presence: {
    message: 'at least one subject is required'
  }
  validates :summary, presence: {
    message: 'Please use the last field at the bottom of this form ' \
      'to summarize your edits to the case.'
  }

  # Avatar uploader using carrierwave
  mount_uploader :avatar, AvatarUploader

  # before_validation :check_for_empty_fields

  # Geocoding
  geocoded_by :full_address
  before_save :geocode, if: proc { |art|
    art.address_changed? || art.city_changed? || art.state_id_changed? || art.zipcode_changed?
  } # auto-fetch coordinates

  before_save :set_default_avatar_url if proc do |art|
    art.avatar.changed?
  end

  # Scopes
  scope :by_state, ->(state_id) { where(state_id: state_id) }
  scope :created_this_month, -> {
    where(created_at: 30.days.ago.beginning_of_day..Time.current)
  }
  scope :most_recent_occurrences, ->(duration) {
    where(date: duration.beginning_of_day..Time.current)
  }
  scope :recently_updated, ->(duration) {
    where(updated_at: duration.beginning_of_day..Time.current)
  }
  scope :sorted_by_update, ->(limit) {
    order('updated_at desc').limit(limit)
  }
  scope :sorted_by_followers, ->(limit) {
    order(follows_count: :desc).first(limit)
  }

  def full_address
    "#{address} #{city} #{state.ansi_code} #{zipcode}".strip
  end

  def set_default_avatar_url
    self.default_avatar_url = avatar.url
  end

  def self.find_by_search(query)
    search(query)
  end

  def nearby_cases
    try(:nearbys, 50).try(:order, 'distance')
  end

  def case_date_cannot_be_in_the_future
    if date.present? && date > Date.current
      errors.add(:date, 'must be in the past')
    end
  end

  def edit_summary
    summary
  end

  # Try building a slug based on the following fields in
  # increasing order of specificity.
  def slug_candidates
    [
      :title,
      %i[title city],
      %i[title city zipcode]
    ]
  end

  def mom_new_cases_growth
    last_month_cases = Case.most_recent_occurrences(30.days.ago).count
    return 0 if last_month_cases.zero?
    last_60_days_cases = Case.most_recent_occurrences(60.days.ago).count
    prior_30_days_cases = last_60_days_cases - last_month_cases
    return (last_month_cases * 100) if prior_30_days_cases.zero?

    (((last_month_cases.to_f / prior_30_days_cases) - 1) * 100).round(2)
  end

  def mom_cases_growth
    last_month_cases = Case.created_this_month.count
    return 0 if last_month_cases.zero?
    previous_cases = Case.count - last_month_cases
    return (last_month_cases * 100) if previous_cases.zero?

    (last_month_cases.to_f / (Case.count - last_month_cases) * 100).round(2)
  end

  def cases_updated_last_30_days
    Case.recently_updated(30.days.ago).count
  end

  def mom_growth_in_case_updates
    last_month_case_updates = Case.recently_updated(30.days.ago).count
    return 0 if last_month_case_updates.zero?
    last_60_days_case_updates = Case.recently_updated(60.days.ago).count
    prior_30_days_case_updates = last_60_days_case_updates - last_month_case_updates
    return (last_month_case_updates * 100) if prior_30_days_case_updates.zero?

    (((last_month_case_updates.to_f / prior_30_days_case_updates) - 1) * 100).round(2)
  end

  private

  def check_for_empty_fields
    attrs = %w[ title date address city state zipcode state_id avatar video_url
                overview community_action litigation country remove_avatar ]
    unless (changed & attrs).any?
      errors[:base] << 'You must change field other than summary to generate a new version'
    end
  end
end
