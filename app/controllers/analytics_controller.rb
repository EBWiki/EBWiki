# frozen_string_literal: true

# Controller for analytics page. A lot of reporting going on.
# TODO: Some of these reports may need to be asynchronous as the data grows
class AnalyticsController < ApplicationController
  def index
    authenticate_user!
    authorize :analytic, :index?
    @last_days = 30
    @full_width_content = true
    @visits_this_month = Visit.this_month
    @visits_today = Visit.today
    @visits_this_week = Visit.this_week
    @users = User.where(created_at: @last_days.days.ago..Time.current)
    @views = Ahoy::Event.where(name: '$view')
    @cases_occurring_this_month = Case.most_recent_occurrences 30.days.ago
    @cases_sorted_by_update = Case.sorted_by_update 10
    @cases_sorted_by_followers = Case.sorted_by_followers 10
    @most_visited_cases = DetermineVisitsToCases.call(@visits_this_week.sorted_by_hits(13))
    @most_recent_comments = Comment.sorted_by_creation 15
  end
end
