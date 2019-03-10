# frozen_string_literal: true

# Controller for analytics page. A lot of reporting going on.
# TODO: Some of these reports may need to be asynchronous as the data grows
class AnalyticsController < ApplicationController

  # rubocop:disable Metrics/MethodLength
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
    @mom_new_cases_growth = Statistics.mom_changed_cases_growth(cases_at_start: Case.most_recent_occurrences(60.days.ago),
                                                                cases_at_end: Case.most_recent_occurrences(30.days.ago))
    @mom_cases_growth = Statistics.mom_cases_growth(cases_at_start: Case.all,
                                                    cases_at_end: Case.created_this_month)
    @cases_updated_last_30_days = Case.recently_updated(30.days.ago).size
    @mom_updated_cases_growth = Statistics.mom_changed_cases_growth(cases_at_start: Case.recently_updated(60.days.ago),
                                                                    cases_at_end: Case.recently_updated(30.days.ago))
    @total_number_of_cases = Case.all.size
  end
  # rubocop:enable Metrics/MethodLength

end
