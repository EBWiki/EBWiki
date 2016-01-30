class MapsController < ApplicationController
  def index
    @articles = Article.by_state(params[:state_id]).search(params[:query], page: params[:page], per_page: 12) if params[:query].present? && params[:state_id].present?
    @articles = Article.by_state(params[:state_id]).order('date DESC').page(params[:page]).per(12) if !params[:query].present? && params[:state_id].present?
    @articles = Article.search(params[:query], page: params[:page], per_page: 12) if params[:query].present? && !params[:state_id].present?
    @articles = Article.all.order('date DESC').page(params[:page]).per(12) if (!params[:query].present? && !params[:state_id].present?)
  end
end
