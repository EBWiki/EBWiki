# frozen_string_literal: true

# Agencies Controller
class AgenciesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :save_my_previous_url, only: %i[new show edit]

  # GET /agencies
  def index
    @agencies = SortCollectionOrdinally.call(collection: Agency.all)
  end

  # GET /agencies/1
  def show
    @agency = Agency.includes(:cases).friendly.find(params[:id])
    @back_url = session[:previous_url]
    @cases = @agency.cases
    @agency_state = @agency.retrieve_state
  end

  # GET /agencies/new
  def new
    @agency = Agency.new
    @states = SortCollectionOrdinally.call(collection: State.all)
  end

  # GET /agencies/1/edit
  def edit
    @agency = Agency.friendly.find(params[:id])
    @states = SortCollectionOrdinally.call(collection: State.all)
  end

  # POST /agencies
  def create
    @back_url = session[:previous_url]
    @agency = Agency.new(agency_params)
    if @agency.save
      flash[:success] = 'Agency was successfully created.'
      redirect_to @back_url, status: :created
    else
      render 'new'
    end
  end

  # PATCH/PUT /agencies/1
  def update
    @agency = Agency.friendly.find(params[:id])
    if @agency.update(agency_params)
      flash[:success] = 'Agency was successfully updated.'
      redirect_to @agency
    else
      render 'edit'
    end
  end

  # DELETE /agencies/1
  def destroy
    @agency = Agency.friendly.find(params[:id])
    @agency.destroy
    flash[:notice] = 'Agency was successfully destroyed.'
    redirect_to agencies_url
  end

  private

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end

  def save_my_previous_url
    # session[:previous_url] is a Rails built-in variable to save last url.
    session[:previous_url] = URI(request.referer || '').path
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def agency_params
    params.require(:agency).permit(:name, :street_address, :city, :state_id,
                                   :zipcode, :telephone, :email, :website,
                                   :jurisdiction)
  end
end
