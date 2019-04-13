# frozen_string_literal: true

# Value object - date range
class DateRange
  attr_reader :start_date, :end_date

  def initialize(start_date:, end_date:)
    @start_date = start_date.beginning_of_day
    @end_date = end_date.end_of_day
  end

  def to_s
    "from #{start_date.strftime('%b %d, %Y')} to #{end_date.strftime('%b %d, %Y')}"
  end

  def ==(other)
    self.class == other.class && self.to_s == other.to_s
  end
end