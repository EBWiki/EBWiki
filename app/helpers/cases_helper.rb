# frozen_string_literal: true

# Helper for case page, mostly the case show page.
module CasesHelper
  YOUTUBE_HOSTS = %w[
    youtube.com
    www.youtube.com
    m.youtube.com
    youtu.be
    youtube-nocookie.com
    www.youtube-nocookie.com
  ].freeze
  VIMEO_HOSTS = %w[vimeo.com www.vimeo.com].freeze
  TRUSTED_VIDEO_SCHEMES = %w[http https].freeze

  def embed(video_url)
    if (youtube_id = youtube_video_id(video_url.to_s))
      content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
    elsif (vimeo_id = vimeo_video_id(video_url.to_s))
      content_tag(:iframe, nil, src: "https://player.vimeo.com/video/#{vimeo_id}")
    else
      content_tag(:iframe, nil, src: video_url.to_s)
    end
  end

  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), this_case
  end

  private

  def youtube_video_id(video_url)
    uri = trusted_uri(video_url, YOUTUBE_HOSTS)
    return unless uri

    youtube_query_video_id(uri) || youtube_path_video_id(uri)
  end

  def youtube_query_video_id(uri)
    URI.decode_www_form(uri.query.to_s).find { |key, _value| key == 'v' }&.last
  end

  def youtube_path_video_id(uri)
    host = uri.host.to_s.downcase
    path_segments = uri.path.split('/').reject(&:empty?)
    return path_segments.first if host == 'youtu.be'
    return path_segments.second if %w[embed v shorts live].include?(path_segments.first)

    nil
  end

  def vimeo_video_id(video_url)
    uri = trusted_uri(video_url, VIMEO_HOSTS)
    return unless uri

    vimeo_path_video_id(uri)
  end

  def vimeo_path_video_id(uri)
    path_segments = uri.path.split('/').reject(&:empty?)
    video_id = path_segments.first
    return video_id if path_segments.length == 1 && video_id&.match?(/\A\d+\z/)

    nil
  end

  def trusted_uri(video_url, allowed_hosts)
    uri = URI.parse(video_url)
    scheme = uri.scheme.to_s.downcase
    host = uri.host.to_s.downcase
    return unless scheme.empty? || TRUSTED_VIDEO_SCHEMES.include?(scheme)
    return unless allowed_hosts.include?(host)

    uri
  rescue URI::InvalidURIError
    nil
  end
end
