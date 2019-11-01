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
    @visits_this_month = EbwikiVisit.this_month
    @visits_this_week = EbwikiVisit.this_week
    @users = User.where(created_at: date_range.start_date..date_range.end_date)
    @views = EbwikiEvent.where(name: '$view')
    @cases_occurring_this_month = Case.most_recent_occurrences 30.days.ago
    @cases_sorted_by_update = Case.sorted_by_update 10
    @cases_sorted_by_followers = Case.sorted_by_followers 10
    @most_visited_cases = DetermineVisitsToCases.call(VisitQuery.new(@visits_this_week).sorted_by_hits(limit: 13))
    @most_recent_comments = Comment.sorted_by_creation 15
    @mom_new_cases_growth = Statistics.metric_growth(start_metric: CaseQuery.new.most_recent_as_of(date: date_range.start_date),
                                                     end_metric: CaseQuery.new.most_recent_as_of(date: date_range.end_date))
    @mom_cases_growth = Statistics.metric_growth(start_metric: CaseQuery.new.created_by(date: date_range.start_date),
                                                 end_metric: CaseQuery.new.created_by(date: date_range.end_date))
    @cases_updated_last_30_days = CaseQuery.new.most_recent_as_of(date: date_range.end_date).count
    @mom_updated_cases_growth = Statistics.metric_growth(start_metric: CaseQuery.new.recently_updated_as_of(date: date_range.start_date),
                                                         end_metric: CaseQuery.new.recently_updated_as_of(date: date_range.end_date))
    @total_number_of_cases = Case.all.size
    @mom_new_visits_growth = Statistics.metric_growth(start_metric: EbwikiVisit.occurring_by(date_range.start_date),
                                                      end_metric: EbwikiVisit.occurring_by(date_range.end_date))
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

  def visits_by_day
    render json: EbwikiVisit.this_month.group_by_day(:started_at).count
  end

  def visits_by_browser
    render json: EbwikiVisit.today.group(:browser).count
  end

  # rubocop:disable Metrics/LineLength
  def users_by_day
    date_range = ThirtyDayPeriod.new(end_date: Date.current)
    render json: User.where(created_at: date_range.start_date..date_range.end_date).group_by_day(:created_at).count
  end
  # rubocop:enable Metrics/LineLength

  def visits_by_referring_domain
    render json: EbwikiVisit.today.group(:referring_domain).count
  end
end
