# frozen_string_literal: true

class AnalyticsController < ApplicationController
  before_action :check_for_admin_or_analyst, only: %i[show index]

  def show; end

  def index
    @last_days = 30
    @full_width_content = true
    @visits = Visit.this_month
    @users = User.where(created_at: @last_days.days.ago..Time.now)
    @views = Ahoy::Event.where(name: '$view')
    @articles = Article.this_month
  end

  private

  def check_for_admin_or_analyst
    authenticate_user!

    return if current_user.admin? || current_user.analyst?
    redirect_to root_url # or whatever
  end
end
