# frozen_string_literal: true

# == Schema Information
#
# Table name: cases
#
#  id                  :integer          not null, primary key
#  address             :string
#  age                 :integer
#  avatar              :string
#  blurb               :text
#  cause_of_death :enum
#  city                :string           not null
#  community_action    :text
#  country             :string
#  date                :date
#  default_avatar_url  :string
#  follows_count       :integer          default(0), not null
#  latitude            :float
#  litigation          :text
#  longitude           :float
#  overview            :text             not null
#  remove_avatar       :boolean
#  slug                :string
#  state               :string
#  summary             :text             not null
#  title               :string           not null
#  video_url           :string
#  zipcode             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  cause_of_death_id   :integer
#  state_id            :integer
#  user_id             :integer
#
# Indexes
#
#  index_cases_on_slug     (slug) UNIQUE
#  index_cases_on_title    (title)
#  index_cases_on_user_id  (user_id)
#
# This is the main model of the application. Each death is a case.
class Case < ApplicationRecord
  # TODO: Clean up relationship section

  MAX_BLURB_CHARACTERS = 500

  enum cause_of_death: {
    choking: 'choking',
    shooting: 'shooting',
    beating: 'beating',
    taser: 'taser',
    vehicular: 'vehicular',
    medical_neglect: 'medical neglect',
    response_to_medical_emergency: 'response to medical emergency',
    suicide: 'suicide',
    chemical_agents_or_weapons: 'chemical_agents_or_weapons',
    stabbing: 'stabbing',
    drowning: 'drowning'
  }

  belongs_to :user
  belongs_to :cause_of_death, optional: true
  belongs_to :state
  has_many :links, dependent: :destroy
  has_many :links, as: :linkable
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :follows, as: :followable, dependent: :destroy
  has_many :subjects
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
  sanitize :title, :city, :address, :zipcode, :overview, :community_action, :country, :litigation,
           :summary, :blurb

  validate :case_date_validator
  validates :city, presence: { message: 'Please add a city.' }
  validates :state_id, presence: {
    message: 'Please specify the state where this incident occurred before saving.'
  }
  validates :title, presence: { message: 'Please specify a title' }
  validates_associated :subjects
  # validates :subjects, presence: {
  #   message: 'at least one subject is required'
  # }
  validates :summary, presence: {
    message: 'Please use the last field at the bottom of this form ' \
      'to summarize your edits to the case.'
  }

  validates_presence_of :overview, message: 'An overview of the case is required'

  validates :blurb, length: { maximum: MAX_BLURB_CHARACTERS }
  validates_presence_of :blurb, message: 'A blurb about the case is required.'

  # Avatar uploader using carrierwave
  mount_uploader :avatar, AvatarUploader

  # Geocoding
  geocoded_by :full_address
  before_save :geocode, if: proc { |art|
    art.address_changed? || art.city_changed? || art.state_id_changed? || art.zipcode_changed?
  } # auto-fetch coordinates

  before_save :set_default_avatar_url if proc do |art|
    art.avatar.changed?
  end

  # Scopes
  scope :most_recent_occurrences, lambda { |duration|
    where(date: duration.beginning_of_day..Time.current)
  }
  scope :sorted_by_update, lambda { |limit|
    order('updated_at desc').limit(limit)
  }
  scope :sorted_by_followers, lambda { |limit|
    order(follows_count: :desc).first(limit)
  }
  scope :with_location, lambda {
    where('latitude is not null AND longitude is not null')
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
    try(:nearbys, 50).try(:order, 'distance') || []
  end

  def case_date_validator
    errors.add(:date, 'must be present') && return unless date.present?

    errors.add(:date, 'must be in the past') if date > Date.current
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
end
