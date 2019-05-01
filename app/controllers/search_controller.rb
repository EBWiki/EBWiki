class SearchController < ApplicationController

  def show
    page_size = 12
    @cases = Case.includes(:state).by_state(params[:state_id]).search(params[:query], page: params[:page], per_page: page_size) if params[:query].present? && params[:state_id].present?
    @cases = Case.includes(:state).by_state(params[:state_id]).order('date DESC').page(params[:page]).per(page_size) if !params[:query].present? && params[:state_id].present?
    @cases = Case.search(params[:query], fields: ['*'], page: params[:page], per_page: page_size) if params[:query].present? && !params[:state_id].present?
  end
end
