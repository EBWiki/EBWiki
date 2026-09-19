# frozen_string_literal: true

require 'uri'

# Builds an iframe for a YouTube or Vimeo URL. Other hosts are ignored.
class VideoEmbed
  YOUTUBE_HOSTS = %w[youtube.com www.youtube.com m.youtube.com].freeze
  VIMEO_HOSTS = %w[vimeo.com www.vimeo.com player.vimeo.com].freeze

  def self.iframe(video_url)
    new(video_url).iframe
  end

  def initialize(video_url)
    @url = video_url.to_s
  end

  def iframe
    return '' if @url.blank?

    youtube_embed || vimeo_embed || ''
  end

  private

  def youtube_embed
    return unless youtube_host?

    youtube_id = @url.split('=').last.to_s[/\A[\w-]+\z/]
    return if youtube_id.blank?

    iframe_tag("//www.youtube.com/embed/#{youtube_id}")
  end

  def vimeo_embed
    return unless vimeo_host?

    vimeo_id = @url.split('/').last.to_s[/\A\d+\z/]
    return if vimeo_id.blank?

    iframe_tag("https://player.vimeo.com/video/#{vimeo_id}")
  end

  def youtube_host?
    YOUTUBE_HOSTS.include?(url_host)
  end

  def vimeo_host?
    VIMEO_HOSTS.include?(url_host)
  end

  def url_host
    URI.parse(@url).host&.downcase
  rescue URI::InvalidURIError
    nil
  end

  def iframe_tag(src)
    ActionController::Base.helpers.content_tag(:iframe, nil, src: src)
  end
end
