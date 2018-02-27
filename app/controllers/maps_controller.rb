# frozen_string_literal: true

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
end
