# frozen_string_literal: true

class AnalyticsController < ApplicationController
  before_action :check_for_admin_or_analyst, only: %i[show index]

  def show; end

  def index
    @last_days = 30
    @full_width_content = true
    @visits_this_month = Visit.this_month
    @visits_today = Visit.today
    @users_this_month = User.this_month
    @views = Ahoy::Event.where(name: '$view')
    @articles = Article.this_month
    @most_recent_articles = Article.most_recent 10
    @most_followed_articles = Article.most_followers 10
    @most_visited_articles = DetermineVisitsToArticles.call(Visit.most_popular(13))
    @most_commented_articles = Article.most_commented 10
  end

  private

  def check_for_admin_or_analyst
    authenticate_user!

    return if current_user.admin? || current_user.analyst?
    redirect_to root_url # or whatever
  end

  
end
