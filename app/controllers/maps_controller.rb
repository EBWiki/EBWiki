# frozen_string_literal: true

# Handle map related actions
class MapsController < ApplicationController
  include MapsHelper

  layout 'maps', only: :globe

  before_action :authenticate_user!, except: %i[index show globe cases]

  def index
    @cases = fetch_cases
  end

  def show
    @cases = fetch_cases
    render :index
  end

  def globe
    @cases_url = cases_maps_path(format: :json)
    @flat_map_url = maps_path
    @open_first_case = params[:open_case].present?
  end

  def cases
    render json: public_case_points
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end
end
