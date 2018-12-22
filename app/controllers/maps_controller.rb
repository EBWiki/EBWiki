# frozen_string_literal: true

class MapsController < ApplicationController
  def index
    set_social_tags
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

  private

  def set_og_tags
    set_meta_tags og: {
      title: 'EBWiki - Mapping Violence Against People of Color',
      type: 'website',
      url: 'https://ebwiki.org/maps',
      description: 'EBWiki is a new web application working to harness the power of community to end bias in law enforcement. This page contains a geographic look at recent cases'
      # image: add_this
    }
  end

  def set_twitter_tags
    set_meta_tags twitter: {
      card: 'summary',
      title: 'EBWiki - Mapping Violence Against People of Color',
      site: @EndBiasWiki,
      url: 'https://ebwiki.org/maps',
      description: 'EBWiki is a new web application working to harness the power of community to end bias in law enforcement. This page contains a geographic look at recent cases'
    }
  end

  def set_social_tags
    set_twitter_tags
    set_og_tags
  end
end
