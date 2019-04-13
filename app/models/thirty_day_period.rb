# frozen_string_literal: true

# Value object - thirty-day period
class ThirtyDayPeriod < DateRange
  def initialize(end_date:)
    start_date = end_date - 30.days
    super(start_date: start_date, end_date: end_date)
  end
end