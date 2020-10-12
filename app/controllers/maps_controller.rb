# frozen_string_literal: true

# Handle map related actions
class MapsController < ApplicationController
  include MapsHelper
  before_action :authenticate_user!, except: %i[index show history followers]

  def index
    @cases = fetch_cases
    @cases = @cases.map do |this_case|
      next if this_case.empty?

      [
        this_case['latitude'], this_case['longitude']
      ]
    end
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end
end
