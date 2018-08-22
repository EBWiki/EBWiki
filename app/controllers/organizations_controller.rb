# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]

  # GET /organizations
  def index
    @organizations = Organization.all
  end

  # GET /organizations/1
  def show; end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit; end

  # POST /organizations
  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      flash[:success] = 'Organization was successfully created.'
      redirect_to @organization
    else
      render 'new'
    end
  end

  # PATCH/PUT /organizations/1
  def update
    if @organization.update(organization_params)
      flash[:success] = 'Organization was successfully updated.'
      redirect_to @organization
    else
      render 'edit'
    end
  end

  # DELETE /organizations/1
  def destroy
    @organization.destroy
    flash[:success] = 'Organization was successfully destroyed.'
    redirect_to organizations_url    
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organization
    @organization = Organization.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def organization_params
    params.require(:organization).permit(:name, :description, :website, :telephone, :avatar)
  end
end
