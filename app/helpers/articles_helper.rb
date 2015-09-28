module ArticlesHelper
  def embed(video_url)
    return '' if video_url.blank?
    youtube_id = video_url.to_s.split("=").last
    content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
  end

  # This method checks to make sure that the article has the instance variables
  # it needs in order to display the content. Intended to gracefully fail in cases
  # where an article doesn't have a subject, for example...
  # TODO: Add the location hash to the list of required data
  def article_sanity_check
  	return (@article.present?	&&
  		@commentable.present? &&
  		@comment.present? &&
  		@subjects.present?)
  end
end
