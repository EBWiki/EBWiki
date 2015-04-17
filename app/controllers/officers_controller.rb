class OfficersController < ApplicationController
  def show
  	@officer=Officer.find(params[:id])
  end
end
