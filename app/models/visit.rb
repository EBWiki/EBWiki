class Visit < ActiveRecord::Base
  has_many :ahoy_events, class_name: "Ahoy::Event"
  belongs_to :user

  scope :property_count_over_time, -> (property, days) { where( "#{property}": "#{days}".to_i.days.ago..Time.now).count }

  def mom_visits_growth
    last_month_visits = Visit.property_count_over_time("started_at", 30)
    last_60_days_visits = Visit.property_count_over_time("started_at", 60)
    prior_30_days_visits = last_60_days_visits - last_month_visits

    return (((last_month_visits.to_f / prior_30_days_visits) - 1) * 100).round(2)
  end
end
