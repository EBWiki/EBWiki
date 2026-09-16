# frozen_string_literal: true

module Admin
  class CommentsController < Admin::ApplicationController
    def index
      @comments = Comment.includes(:user, :commentable).order(created_at: :desc)
                         .page(params[:page]).per(25)
    end

    def destroy
      comment = Comment.find(params[:id])
      comment.destroy
      flash[:success] = 'Comment deleted.'
      redirect_to admin_comments_path
    end
  end
end
