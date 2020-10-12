# frozen_string_literal: true

# Helper for case page, mostly the casw show page.
module CasesHelper
  def embed(video_url)
    if video_url.include? 'youtube.com'
      youtube_id = video_url.to_s.split('=').last
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
end
