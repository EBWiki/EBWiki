class ArticlesController < ApplicationController
	before_action :find_article, only: [:show, :edit, :update, :destroy]
	before_action :authenticate_user!, except: [:index, :show]

	def index
	    if params[:query].present?
	      @articles = Article.search("#{params[:query]}")
	    else
	      @articles = Article.all.order('updated_at DESC')
	    end
    end

	def new
		@article = current_user.articles.build
	end

	def show
		@officers = @article.officers.all
	end

	def create
		@article = current_user.articles.build(article_params)
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
		params.require(:article).permit(:title, :age, :content, :category_id, :date, :state_id, :city, :address, :zipcode, :longitude, :latitude, :avatar, :video_url, links_attributes: [:id, :url, :_destroy], officers_attributes: [:first_name, :last_name, :title, :avatar, :id, :_destroy])
	end
end
