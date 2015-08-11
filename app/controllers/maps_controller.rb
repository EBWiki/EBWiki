class MapsController < ApplicationController
  def index
	  if params[:state_id].present?
	  	@articles_by_state = Article.where(state_id: params[:state_id])
	    if params[:query].present?
	      @articles = Article.search("#{params[:query]}", where: {state_id: params[:state_id]})
	    else
	      @articles = @articles_by_state.all
	    end
	  else
	    if params[:query].present?
	      @articles = Article.search("#{params[:query]}")
	    else
	      @articles = Article.all
	    end
	  end

    @hash = Gmaps4rails.build_markers(@articles) do |article, marker|
		  marker.lat article.latitude
		  marker.lng article.longitude
		  marker.infowindow render_to_string(:partial => "/articles/info_window", :locals => { :article => article})
		end
  end
end
