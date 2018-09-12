# frozen_string_literal: true

# Case comments controller
class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    @commentable = load_commentable
    @comments = @commentable.comments
  end

  def new
    @commentable = load_commentable
    @comment = @commentable.comments.new
  end

  def create
    @commentable = load_commentable
    @comment = @commentable.comments.new comment_params
    @comment.user = current_user
    @comment.save
    redirect_to @commentable, notice: 'Comment created!', status: :created
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end

  private

  def load_commentable
    resource, id = request.path.split('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id)
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
