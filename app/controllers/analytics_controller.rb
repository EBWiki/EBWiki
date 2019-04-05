# frozen_string_literal: true

# Controller for analytics page. A lot of reporting going on.
# TODO: Some of these reports may need to be asynchronous as the data grows
class AnalyticsController < ApplicationController
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/LineLength
  # rubocop:disable Metrics/AbcSize
  def index
    authenticate_user!
    authorize :analytic, :index?
    @last_days = 30
    @full_width_content = true
    @visits_this_month = Ahoy::Visit.this_month
    @visits_today = Ahoy::Visit.today
    @visits_this_week = Ahoy::Visit.this_week
    @users = User.where(created_at: @last_days.days.ago..Time.current)
    @views = Ahoy::Event.where(name: '$view')
    @cases_occurring_this_month = Case.most_recent_occurrences 30.days.ago
    @cases_sorted_by_update = Case.sorted_by_update 10
    @cases_sorted_by_followers = Case.sorted_by_followers 10
    @most_visited_cases = DetermineVisitsToCases.call(@visits_this_week.sorted_by_hits(13))
    @most_recent_comments = Comment.sorted_by_creation 15
    @mom_new_cases_growth = Statistics.mom_changed_metric_growth(metric_at_start: CaseQuery.new.most_recent_as_of(date: 30.days.ago),
                                                                 metric_at_end: CaseQuery.new.most_recent_as_of(date: Date.current))
    @mom_cases_growth = Statistics.mom_total_metric_growth(metric_at_start: CaseQuery.new.created_by(date: 30.days.ago),
                                                           metric_at_end: CaseQuery.new.created_by(date: Date.current))
    @cases_updated_last_30_days = Case.recently_updated(30.days.ago).size
    @mom_updated_cases_growth = Statistics.mom_changed_metric_growth(metric_at_start: CaseQuery.new.recently_updated_as_of(date: 30.days.ago),
                                                                     metric_at_end: CaseQuery.new.recently_updated_as_of(date: Date.current))
    @total_number_of_cases = Case.all.size
    @mom_new_visits_growth = Statistics.mom_changed_metric_growth(metric_at_start: Ahoy::Visit.occurring_by(30.days.ago),
                                                                  metric_at_end: Ahoy::Visit.occurring_by(Date.current))
    @total_number_of_follows = Follow.all.size
    @mom_follows_growth = Statistics.mom_total_metric_growth(metric_at_start: Follow.occurring_by(30.days.ago),
                                                             metric_at_end: Follow.occurring_by(Date.current))
    @total_distinct_follows = FollowQuery.new.distinct_count
    @mom_unique_followers_growth = Statistics.mom_unique_followers_growth(metric_at_start: Follow.occurring_by(30.days.ago),
                                                                          metric_at_end: Follow.occurring_by(Date.current))
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/LineLength
  # rubocop:enable Metrics/AbcSize
end
