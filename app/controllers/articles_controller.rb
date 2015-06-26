class ArticlesController < ApplicationController
	before_action :find_article, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  #before_action :set_commentable

	def index
	    if params[:query].present?
	      @articles = Article.search("#{params[:query]}")
	    else
	      @articles = Article.all.order('updated_at DESC')
	    end
	    articles_copy = @articles.dup
	    @hash = Gmaps4rails.build_markers(articles_copy) do |article, marker|
			  marker.lat article.latitude
			  marker.lng article.longitude
			  marker.infowindow render_to_string(:partial => "/articles/info_window", :locals => { :article => article})
			end
    end

	def new
		@article = current_user.articles.build
	end

	def show
		@article = Article.friendly.find(params[:id])
		@officers = @article.officers.all
		@commentable = @article
		@comments = @commentable.comments
		@comment = Comment.new

    @hash = Gmaps4rails.build_markers(@article.nearby_cases) do |article, marker|
		  marker.lat article.latitude
		  marker.lng article.longitude
		  marker.infowindow render_to_string(:partial => "/articles/info_window", :locals => { :article => article})
		end
	end

	def create
		@article = current_user.articles.build(article_params)
		# This could be a very expensive query as the userbase gets larger.
		# TODO: Create a scope to send only to users who have chosen to receive email updates
		@users = User.all
		if @article.save
		    flash[:success] = "Article was created! #{make_undo_link}"
			redirect_to @article
		else
			render 'new'
		end
	end

	def edit
	end

	def update
	  @article = Article.friendly.find(params[:id])
	  if @article.update_attributes(article_params)
	    flash[:success] = "Article was updated! #{make_undo_link}"
		redirect_to @article
	  else
	    render 'edit'
	  end
	end

	def destroy
		@article.destroy
	    flash[:success] = "Article was removed! #{make_undo_link}"
		redirect_to root_path
	end

	def history
		@article = Article.friendly.find(params[:id])
		@versions = @article.versions.order('created_at DESC')
	end

	def undo
	  @article_version = PaperTrail::Version.find_by_id(params[:id])

	  begin
	    if @article_version.reify
	      @article_version.reify.save
	    else
	      # For undoing the create action
	      @article_version.item.destroy
	    end
	    flash[:success] = "Undid that! #{make_redo_link}"
	  rescue
	    flash[:alert] = "Failed undoing the action..."
	  ensure
	    redirect_to root_path
	  end
	end

private

	def find_article
		@article = Article.friendly.find(params[:id])
	end

	def make_undo_link
	  view_context.link_to 'Undo that please!', undo_path(@article.versions.last), method: :post
	end

	def make_redo_link
	  params[:redo] == "true" ? link = "Undo that please!" : link = "Redo that please!"
	  view_context.link_to link, undo_path(@article_version.next, redo: !params[:redo]), method: :post
	end

	def article_params
		params.require(:article).permit(:title, :age, :content, :overview, :litigation, :community_action, :agency_id, :category_id, :date, :state_id, :city, :address, :zipcode, :longitude, :latitude, :avatar, :video_url, links_attributes: [:id, :url, :_destroy], officers_attributes: [:first_name, :last_name, :title, :avatar, :id, :_destroy], events_attributes: [:id, :title, :description, :date, :media_url, :media_credit, :done, :_destroy], comments_attributes: [:comment, :content, :commentable_id, :commentable_type])
	end

	# from the tutorial (https://gorails.com/episodes/comments-with-polymorphic-associations)
	# why did they set commentable here?
	def set_commentable
		@commentable = Article.friendly.find(params[:id])
	end
end
