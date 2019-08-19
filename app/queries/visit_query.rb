# frozen_string_literal: true

# Query objects for visits
class VisitQuery
  def initialize(scope = Ahoy::Visit.all)
    @scope = scope
  end

  def sorted_by_hits(limit:)
    @scope.group(:landing_page).order('count_id DESC').limit(limit).count(:id)
  end
end
