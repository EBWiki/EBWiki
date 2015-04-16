module ArticlesHelper
  def embed(video_url)
    return '' if video_url.blank?
    youtube_id = video_url.to_s.split("=").last
    content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
  end
end
