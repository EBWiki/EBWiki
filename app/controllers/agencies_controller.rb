class AgenciesController < ApplicationController
  def show
  	@agency = Agency.friendly.find(params[:id])
  	@articles = @agency.articles.order ("date DESC")
  end
end
