class SearchController < ApplicationController
  def show
    @cases = CaseSearch.new(query: params[:query], options: search_params).call
    @presenter = SearchPresenter.new(query: params[:query],
                                     state_id: params[:state_id],
                                     count: @cases.total_count,
                                     view: view_context)
  end

  private

  def search_params
    params.permit :page, :state_id
  end
end
