# frozen_string_literal: true

class MapsController < ApplicationController
  def index
    @articles = Article.pluck(:id,
                              :latitude,
                              :longitude,
                              :avatar,
                              :title,
                              :overview)

    # Substitute avatar URL for empty object in 4th variable
    @articles.each do |article|
      article[3] = Article.find_by_id(article[0]).avatar.medium_avatar.to_s
    end
  end
end
