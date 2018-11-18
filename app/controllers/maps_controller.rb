# frozen_string_literal: true

# Handle map related actions
class MapsController < ApplicationController
  def index
    @cases = Case.pluck(:id,
                        :latitude,
                        :longitude,
                        :avatar,
                        :title,
                        :overview)

    # Substitute avatar URL for empty object in 4th variable
    @cases.each do |this_case|
      this_case[3] = Case.find_by_id(this_case[0]).avatar.medium_avatar.to_s
    end
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end
end
