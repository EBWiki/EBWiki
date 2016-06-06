class Visit < ActiveRecord::Base
  has_many :ahoy_events, class_name: "Ahoy::Event"
  belongs_to :user

  def mom_visits_growth
    last_month_visits = Visit.where(started_at: 30.days.ago..Time.now).count
    last_60_days_visits = Visit.where(started_at: 60.days.ago..Time.now).count
    prior_30_days_visits = last_60_days_visits - last_month_visits

    return (((last_month_visits.to_f / prior_30_days_visits) - 1) * 100).round(2)
  end
end
