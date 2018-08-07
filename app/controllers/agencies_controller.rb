# frozen_string_literal: true

# Agencies Controller
class AgenciesController < ApplicationController
  before_action :set_agency, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: %i[index show]
  after_filter 'save_my_previous_url', only: %i[new show edit]

  # GET /agencies
  def index
    @agencies = SortCollectionOrdinally.call(Agency.all)
  end

  # GET /agencies/1
  def show
    @back_url = session[:previous_url]
    @cases = @agency.cases
    @agency_state = @agency.retrieve_state
  end

  # GET /agencies/new
  def new
    @agency = Agency.new
  end

  # GET /agencies/1/edit
  def edit; end

  # POST /agencies
  def create
    @back_url = session[:previous_url]
    @agency = Agency.new(agency_params.except(:jurisdiction))
    @agency.jurisdiction_type = params[:jurisdiction] 
    if @agency.save
      flash[:success] = "Agency was successfully created. #{make_undo_link}"
      redirect_to @agency
    else
      render "new"
    end 
  end

  # PATCH/PUT /agencies/1
  def update
    if @agency.update(agency_params.except(:jurisdiction))
      @agency.jurisdiction_type = params[:jurisdiction]     
      flash[:success] = "Agency was successfully updated. #{make_undo_link}"
      redirect_to @agency
    else
      render "edit"
    end
  end

  def destroy
    @agency.destroy
    respond_to do |format|
      format.html { redirect_to agencies_path, 
                    notice: "Agency was successfully destroyed. #{make_undo_link}" }
    end
  end

  def history
    @agency_history = @agency.try(:versions).order(created_at: :desc) unless
    @agency.blank? || @agency.versions.blank?
  end

  def undo
    @agency_version = PaperTrail::Version.find_by_id(params[:id])
    begin
      if @agency_version.reify
        @agency_version.reify.save
      else
        @agency_version.item.destroy
      end
      flash[:success] = "Undid that! #{make_redo_link}"
    rescue
      flash[:alert] = 'Action failed'
    ensure
      redirect_to root_path
    end
  end

  private

  def make_undo_link
    view_context.link_to 'Click here to undo', 
      agency_undo_path(@agency.versions.last), method: :post
  end

  def make_redo_link
    params[:redo] == 'true' ? link = 'Click here to undo' : link = 'Click here to redo!'
    view_context.link_to link, agency_undo_path(@agency_version.next, 
        redo: !params[:redo]), method: :post
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_agency
    @agency = Agency.friendly.find(params[:id])
  end

  def save_my_previous_url
    # session[:previous_url] is a Rails built-in variable to save last url.
    session[:previous_url] = URI(request.referer || '').path
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def agency_params
    params.require(:agency).permit(I18n.t('agencies_controller.agency_params').map(&:to_sym))
  end
end