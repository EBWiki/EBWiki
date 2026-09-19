# frozen_string_literal: true

require 'uri'

# Helper for case page, mostly the case show page.
module CasesHelper
  YOUTUBE_HOSTS = %w[youtube.com www.youtube.com m.youtube.com].freeze
  VIMEO_HOSTS = %w[vimeo.com www.vimeo.com player.vimeo.com].freeze

  def embed(video_url)
    url = video_url.to_s
    return '' if url.blank?

    youtube_embed(url) || vimeo_embed(url) || ''
  end

  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), case_path(this_case.id)
  end

  private

  def youtube_embed(url)
    return unless youtube_host?(url)

    youtube_id = url.split('=').last.to_s[/\A[\w-]+\z/]
    return if youtube_id.blank?

    content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
  end

  def vimeo_embed(url)
    return unless vimeo_host?(url)

    vimeo_id = url.split('/').last.to_s[/\A\d+\z/]
    return if vimeo_id.blank?

    content_tag(:iframe, nil, src: "https://player.vimeo.com/video/#{vimeo_id}")
  end

  def youtube_host?(url)
    YOUTUBE_HOSTS.include?(url_host(url))
  end

  def vimeo_host?(url)
    VIMEO_HOSTS.include?(url_host(url))
  end

  def url_host(url)
    URI.parse(url).host&.downcase
  rescue URI::InvalidURIError
    nil
  end
end
