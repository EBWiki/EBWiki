class AgenciesController < ApplicationController
  def show
  	@agency = Agency.friendly.find(params[:id])
  end
end
