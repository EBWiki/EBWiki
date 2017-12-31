# frozen_string_literal: true

module AnalyticsHelper
  def case_updates
    # returns all versions of all cases created in the last 30 days
    PaperTrail::Version.where('created_at > ?', 30.days.ago)
  end

  def case_updaters_count(how_many)
    # returns list of uniq editors of case updates along woth thenumber of updates each has authored
    case_updates.group(:whodunnit).order('count_id DESC').limit(how_many).count(:id)
  end

  def total_follows_count
    Follow.count
  end

  def mom_visits_growth
    Visit.first.mom_visits_growth
  end

  def cases_updated_last_30_days
    Article.first.cases_updated_last_30_days
  end

  def mom_growth_in_case_updates
    Article.first.mom_growth_in_case_updates
  end

  def total_number_of_cases
    Article.count
  end

  def total_cases_mom
    Article.first.mom_cases_growth
  end

  def mom_follows_growth
    Follow.first.mom_follows_growth
  end

  def unique_followers_count
    Follow.distinct.count('follower_id')
  end

  def mom_uniq_followers_growth
    Follow.first.mom_uniq_followers_growth
  end

  def mom_new_cases_growth
    Article.first.mom_new_cases_growth
  end

  def most_recently_updated_cases
    Article.order(updated_at: :desc).first(10)
  end

  def ten_most_followed_cases
    Article.order(follows_count: :desc).first(10)
  end

  def visits_over_the_past_7_days
    Visit.where(started_at: 7.days.ago..Time.now)
  end

  def visits_over_the_past_7_days_by_landing_page
    visits_over_the_past_7_days.group(:landing_page).order('count_id DESC').limit(13).count(:id)
  end

  def landing_page_was_a_case?(visit)
    Article.find_by_slug(visit[0].split('/').last).present?
  end

  def landing_page_from_visit(visit)
    Article.find_by_slug(visit[0].split('/').last)
  end

  def editor(user_id)
    User.find(user_id)
  end
end
