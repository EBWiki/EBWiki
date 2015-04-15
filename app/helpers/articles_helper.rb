module ArticlesHelper
  def embed(video_url)
    youtube_id = video_url.split("=").last
    content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
  end
end
