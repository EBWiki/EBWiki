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
    date_range = ThirtyDayPeriod.new(end_date: Date.current)
    @full_width_content = true
    @visits_this_month = Ahoy::Visit.this_month
    @visits_today = Ahoy::Visit.today
    @visits_this_week = Ahoy::Visit.this_week
    @users = User.where(created_at: date_range.start_date..date_range.end_date)
    @views = Ahoy::Event.where(name: '$view')
    @cases_occurring_this_month = Case.most_recent_occurrences 30.days.ago
    @cases_sorted_by_update = Case.sorted_by_update 10
    @cases_sorted_by_followers = Case.sorted_by_followers 10
    @most_visited_cases = DetermineVisitsToCases.call(VisitQuery.new(@visits_this_week).sorted_by_hits(limit: 13))
    @most_recent_comments = Comment.sorted_by_creation 15
    @mom_new_cases_growth = Statistics.metric_growth(start_metric: CaseQuery.new.most_recent_as_of(date: date_range.start_date),
                                                     end_metric: CaseQuery.new.most_recent_as_of(date: date_range.end_date))
    @mom_cases_growth = Statistics.metric_growth(start_metric: CaseQuery.new.created_by(date: date_range.start_date),
                                                 end_metric: CaseQuery.new.created_by(date: date_range.end_date))
    @cases_updated_last_30_days = Case.recently_updated(30.days.ago).size
    @mom_updated_cases_growth = Statistics.metric_growth(start_metric: CaseQuery.new.recently_updated_as_of(date: date_range.start_date),
                                                         end_metric: CaseQuery.new.recently_updated_as_of(date: date_range.end_date))
    @total_number_of_cases = Case.all.size
    @mom_new_visits_growth = Statistics.metric_growth(start_metric: Ahoy::Visit.occurring_by(date_range.start_date),
                                                      end_metric: Ahoy::Visit.occurring_by(date_range.end_date))
    @total_number_of_follows = Follow.all.size
    @mom_follows_growth = Statistics.metric_growth(start_metric: Follow.occurring_by(date_range.start_date),
                                                   end_metric: Follow.occurring_by(date_range.end_date))
    @total_distinct_follows = FollowQuery.new.distinct_count
    @unique_followers_growth = Statistics.unique_followers_growth(start_metric: Follow.occurring_by(date_range.start_date),
                                                                  end_metric: Follow.occurring_by(date_range.end_date))
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/LineLength
  # rubocop:enable Metrics/AbcSize
end
