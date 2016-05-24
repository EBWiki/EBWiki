class AnalyticsController < ApplicationController
  def show
  end

  def index
    @full_width_content = true
    @visits = Visit.all
    @views = Ahoy::Event.where(name: '$view' )
  end
end
