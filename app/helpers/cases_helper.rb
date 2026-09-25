# frozen_string_literal: true

# Helper for case page, mostly the casw show page.
module CasesHelper
  YOUTUBE_HOSTS = %w[
    youtube.com
    www.youtube.com
    m.youtube.com
    youtu.be
    youtube-nocookie.com
    www.youtube-nocookie.com
  ].freeze

  def embed(video_url)
    if (youtube_id = youtube_video_id(video_url.to_s))
      content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
    elsif video_url.include? 'vimeo.com'
      vimeo_id = video_url.to_s.split('.com/').last
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
    uri = URI.parse(video_url)
    host = uri.host.to_s.downcase
    return unless YOUTUBE_HOSTS.include?(host)

    URI.decode_www_form(uri.query.to_s).to_h['v'] || youtube_path_video_id(uri, host)
  rescue URI::InvalidURIError
    nil
  end

  def youtube_path_video_id(uri, host)
    path_segments = uri.path.split('/').reject(&:empty?)
    return path_segments.first if host == 'youtu.be'
    return path_segments.second if %w[embed v shorts live].include?(path_segments.first)

    nil
  end
end
