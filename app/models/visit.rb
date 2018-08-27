# frozen_string_literal: true

# Visit capturing user activity for Ahoy:
# https://github.com/ankane/ahoy
class Visit < ApplicationRecord
  has_many :ahoy_events, class_name: 'Ahoy::Event'
  belongs_to :user

  scope :this_month, -> { where(started_at: 30.days.ago.beginning_of_day..Time.current) }
  scope :this_week, -> { where(started_at: 7.days.ago.beginning_of_day..Time.current) }
  scope :today, -> { where(started_at: 1.days.ago.beginning_of_day..Time.current) }
  scope :most_recent, ->(duration) { where(started_at: duration.beginning_of_day..Time.current) }
  scope :sorted_by_hits, ->(limit) { group(:landing_page).order('count_id DESC').limit(limit).count(:id) }

  def mom_visits_growth
    last_month_visits = Visit.this_month.count
    return 0 if last_month_visits.zero?
    last_60_days_visits = Visit.most_recent(60.days.ago).count
    prior_30_days_visits = last_60_days_visits - last_month_visits
    return (last_month_visits * 100) if prior_30_days_visits.zero?

    (((last_month_visits.to_f / prior_30_days_visits) - 1) * 100).round(2)
  end
end
