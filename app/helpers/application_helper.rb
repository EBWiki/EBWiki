module ApplicationHelper
  

  def active_page(active_page)
    @active == active_page ? "active" : ""
  end
  
	def avatar_url(user,size)
    default_url = "#{root_url}default-user-icon.png"
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end

  def filter
  	if params[:controller] == "maps"
  		"/maps/index"
  	else
  		'articles'
  	end
  end

  def marker_locations_for(articles)
    return nil if articles.blank?
    @hash = Gmaps4rails.build_markers(articles.dup) do |article, marker|
      marker.lat article.latitude
      marker.lng article.longitude
      marker.infowindow controller.render_to_string(:partial => "/articles/info_window", :locals => { :article => article})
    end
    @hash
  end
  
  def state_dropdown
    select_tag(:state_id, 
      options_from_collection_for_select(State.all, :id, :name), 
      include_blank: "Filter By State...",
      class: 'form-control select2')
  end
  
  def state_search_input
    text_field_tag :query, params[:query], 
      class: 'form-control', 
      data: { list: State.all.map(&:name) } , 
      placeholder: 'Name, City or Keywords...'
  end
end
