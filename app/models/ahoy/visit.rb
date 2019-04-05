# frozen_string_literal: true

# Visit capturing user activity for Ahoy:
# https://github.com/ankane/ahoy
class Ahoy::Visit < ActiveRecord::Base
  has_many :ahoy_events, class_name: 'Ahoy::Event'
  belongs_to :user

  scope :this_month, -> { where(started_at: 30.days.ago.beginning_of_day..Time.current) }
  scope :this_week, -> { where(started_at: 7.days.ago.beginning_of_day..Time.current) }
  scope :today, -> { where(started_at: 1.days.ago.beginning_of_day..Time.current) }
  scope :most_recent, ->(duration) { where(started_at: duration.beginning_of_day..Time.current) }
  scope :sorted_by_hits, ->(limit) {
    group(:landing_page).order('count_id DESC').limit(limit).count(:id)
  }
  scope :occurring_by, ->(date) { where("started_at < ?", date.end_of_day) }
end
