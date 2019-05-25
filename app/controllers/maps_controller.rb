# frozen_string_literal: true

# Handle map related actions
class MapsController < ApplicationController
  include MapsHelper
  def index
    @cases = fetch_cases
    @cases = @cases.map do |this_case|
      [
        this_case['id'], this_case['latitude'],
        this_case['longitude'], this_case['avatar'],
        this_case['title'], this_case['overview']
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
