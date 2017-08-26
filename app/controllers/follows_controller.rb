class FollowsController < ApplicationController
  before_action :authenticate_user!
  
  def create
	  @article = Article.find(params[:article_id])
    current_user.follow(@article)
    redirect_to @article
  end

  def destroy
  	@article = Article.find(params[:article_id])    
    current_user.stop_following(@article)
    redirect_to @article
  end
end
