class SearchController < ApplicationController
  def show
    @cases = CaseSearch.new(query: params[:query], options: search_params).call
  end

  private

  def search_params
    params.permit :page, :state_id
  end
end
