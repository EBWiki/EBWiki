# frozen_string_literal: true

class Visit < ActiveRecord::Base
  has_many :ahoy_events, class_name: 'Ahoy::Event'
  belongs_to :user

  scope :this_month, -> { where(started_at: 30.days.ago..Date.today) }
  scope :today, -> { where(started_at: 1.days.ago..Date.today) }
  scope :property_count_over_time, ->(property, days) { where("#{property}": days.to_s.to_i.days.ago..Time.now).count }
  scope :most_popular, -> (limit) { where(started_at: 7.days.ago..Date.today).group(:landing_page).order('count_id DESC').limit(limit).count(:id)}

  def mom_visits_growth
    last_month_visits = Visit.property_count_over_time('started_at', 30)
    last_60_days_visits = Visit.property_count_over_time('started_at', 60)
    prior_30_days_visits = last_60_days_visits - last_month_visits

    (((last_month_visits.to_f / prior_30_days_visits) - 1) * 100).round(2)
  end

end
