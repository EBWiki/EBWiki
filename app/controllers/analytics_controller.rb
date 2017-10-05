class AnalyticsController < ApplicationController
  before_action :check_for_admin_or_analyst, only: [:show, :index]

  def show
  end

  def index
    @last_days = 30
    @full_width_content = true
    @visits = Visit.where(started_at: @last_days.days.ago..Time.now)
    @users = User.where(created_at: @last_days.days.ago..Time.now)
    @views = Ahoy::Event.where(name: '$view' )
  end

private
  def check_for_admin_or_analyst
    authenticate_user!

    if current_user.admin?
      return
    elsif current_user.analyst?
      return
    else
      redirect_to root_url # or whatever
    end
  end
end
