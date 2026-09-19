# frozen_string_literal: true

# Case comments controller
class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    @commentable = load_commentable
    @comments = @commentable.comments
  end

  def create
    @commentable = load_commentable
    @comment = @commentable.comments.new comment_params
    @comment.user = current_user
    if @comment.save
      redirect_to @commentable, notice: 'Comment added.'
    else
      redirect_to @commentable,
                  alert: 'Comment could not be added. Write the comment before submitting.'
    end
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
    params.expect(comment: [:content])
  end
end
