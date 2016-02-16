module CaseFiltering
  extend ActiveSupport::Concern

  def index
  	finished(:viewed_maps, reset: false)
    page_size = 12
    @articles = Article.by_state(params[:state_id]).search(params[:query], page: params[:page], per_page: page_size) if params[:query].present? && params[:state_id].present?
    @articles = Article.by_state(params[:state_id]).order('date DESC').page(params[:page]).per(page_size) if !params[:query].present? && params[:state_id].present?
    @articles = Article.search(params[:query], page: params[:page], per_page: page_size) if params[:query].present? && !params[:state_id].present?
    @articles = Article.all.order('date DESC').page(params[:page]).per(page_size) if (!params[:query].present? && !params[:state_id].present?)
  end
end