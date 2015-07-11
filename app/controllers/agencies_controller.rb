class AgenciesController < ApplicationController
  def show
  end

private

	def agency_params
		params.require(:agency).permit(:title, :website)
	end
end
