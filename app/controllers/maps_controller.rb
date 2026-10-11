# frozen_string_literal: true

# Handle map related actions
class MapsController < ApplicationController
  include MapsHelper

  layout 'maps'

  before_action :authenticate_user!, except: %i[index show globe cases]

  def index
    @cases = fetch_cases
  end

  def show
    @cases = fetch_cases
    render :index
  end

  def globe
    @cases_url = cases_maps_url(format: :json)
    @flat_map_url = maps_url
    @google_3d_api_key = ENV.fetch('GOOGLE_MAPS_3D_TILES_API_KEY', '')
    @cesium_ion_token = ENV.fetch('CESIUM_ION_ACCESS_TOKEN', '')
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
