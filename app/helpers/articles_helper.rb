module ArticlesHelper
  def embed(video_url)
    return '' if video_url.blank?
    youtube_id = video_url.to_s.split("=").last
    content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}")
  end

  def marker_locations_for(articles)
  	return nil if articles.blank?
	  hash = Gmaps4rails.build_markers(articles.dup) do |article, marker|
		  marker.lat article.latitude
		  marker.lng article.longitude
		  marker.infowindow controller.render_to_string(:partial => "/articles/info_window", :locals => { :article => article})
		end
	end
end
