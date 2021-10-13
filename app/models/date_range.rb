# frozen_string_literal: true

# Value object - date range
class DateRange < ValueObject
  attr_reader :start_date, :end_date

  def initialize(start_date:, end_date:) # rubocop:disable Lint/MissingSuper
    @start_date = start_date.beginning_of_day
    @end_date = end_date.end_of_day
  end

  def to_s
    "from #{start_date.to_s(:short_date)} to #{end_date.to_s(:short_date)}"
  end
end
