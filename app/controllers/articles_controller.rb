class ArticlesController < ApplicationController
	before_action :find_article, only: [:show]

	def index
		@articles = Article.all.order('created_at DESC')
	end

	def new
		@article = Article.new
	end

	def show
		
	end

	def create
		@article = Article.new(article_params)
		if @article.save
			redirect_to @article
		else
			render 'new'
		end
	end

private

	def find_article
		@article = Article.find(params[:id])
	end

	def article_params
		params.require(:article).permit(:title, :content)
	end
end
