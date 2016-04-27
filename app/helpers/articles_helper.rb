module ArticlesHelper
  def embed(video_url)
    return '' if video_url.blank?
    if video_url.include? "youtube.com"
      youtube_id = video_url.to_s.split("=").last
      content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
    elsif video_url.include? "vimeo.com"
      vimeo_id = video_url.to_s.split(".com/").last
      content_tag(:iframe, nil, src: "https://player.vimeo.com/video/#{vimeo_id}")
    end
  end

  # This method checks to make sure that the article has the instance variables
  # it needs in order to display the content. Intended to gracefully fail in cases
  # where an article doesn't have a subject, for example...
  # TODO: Add the location hash to the list of required data
  def article_sanity_check
    return (@article.present? &&
      @commentable.present? &&
      @comment.present? &&
      @subjects.present?)
  end

  # method to help with genders
  def gender_dropdown_collection
    Gender.all.map {|gender| [gender.sex, gender.id]}.insert(3, "--------")
  end
end
