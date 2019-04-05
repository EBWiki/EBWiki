# frozen_string_literal: true

# Query objects for cases
class CaseQuery
  def initialize(scope = Case.all)
    @scope = scope
  end

  # Get the most recent cases as of a date, where most recent is occurring
  # within 30 days of the date
  def most_recent_as_of(date:)
    period_begin = date - 30.days
    created_by(date: date)
    .where(date: period_begin.beginning_of_day..date.end_of_day)
  end

  def created_by(date:)
    @scope.where("created_at < ?", date.end_of_day)
  end

  # Get the most recently updated cases of a date, where most recent is
  # within 30 days of the date
  def recently_updated_as_of(date:)
    period_begin = date - 30.days
    created_by(date: date)
    .where(updated_at: period_begin.beginning_of_day..date.end_of_day)
  end
end