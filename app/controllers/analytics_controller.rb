class AnalyticsController < ApplicationController
  before_action :custom_method, :only => [:show, :index]

  def show
  end

  def index
    @last_days = 30
    @full_width_content = true
    @visits = Visit.where(started_at: @last_days.days.ago..Time.now)
    @views = Ahoy::Event.where(name: '$view' )
  end

private
  def custom_method
    authenticate_user!

    if current_user.admin
       return
    else
       redirect_to root_url # or whatever
    end
  end
end
