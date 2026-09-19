# frozen_string_literal: true

# Helper for case page, mostly the casw show page.
module CasesHelper
  def embed(video_url)
    url = video_url.to_s
    return '' if url.blank?

    if url.include?('youtube.com')
      youtube_id = url.split('=').last.to_s[/\A[\w-]+\z/]
      return '' if youtube_id.blank?

      content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
    elsif url.include?('vimeo.com')
      vimeo_id = url.split('.com/').last.to_s[/\A\d+\z/]
      return '' if vimeo_id.blank?

      content_tag(:iframe, nil, src: "https://player.vimeo.com/video/#{vimeo_id}")
    else
      ''
    end
  end

  def link_to_case_title(this_case, length)
    link_to truncate(this_case.title, length: length), case_path(this_case.id)
  end
end
