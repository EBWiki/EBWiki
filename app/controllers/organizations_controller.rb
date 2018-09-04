# frozen_string_literal: true

# Organizations controller
class OrganizationsController < ApplicationController
  # GET /organizations
  def index
    @organizations = Organization.all
  end

  # GET /organizations/1
  def show
    @organization = Organization.find(params[:id])
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit
    @organization = Organization.find(params[:id])
  end

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
    @organization = Organization.find(params[:id])
    if @organization.update(organization_params)
      flash[:success] = 'Organization was successfully updated.'
      redirect_to @organization
    else
      render 'edit'
    end
  end

  # DELETE /organizations/1
  def destroy
    @organization = Organization.find(params[:id])
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def organization_params
    params.require(:organization).permit(:name, :description, :website, :telephone, :avatar)
  end
end
