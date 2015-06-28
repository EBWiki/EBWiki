class CommentsController < ApplicationController
	before_filter :load_commentable
  before_action :authenticate_user!, only: [:create]

  def index
  	@comments = @commentable.comments
  end

  def new
  	@comment =@commentable.comments.new
  end

  def create
  	@comment = @commentable.comments.new comment_params
    @comment.user = current_user
  	@comment.save
  	redirect_to @commentable, notice: "Comment created!"
  end

private
	def load_commentable
		resource, id = request.path.split('/')[1,2]
		@commentable = resource.singularize.classify.constantize.find(id)		
	end

	def comment_params
		params.require(:comment).permit(:content)
	end

	# alternate method --
	# def load_commentable
	# 	klass = [Article, Photo, Event].detect {|c| params["#{c.name.underscore}"_id]}
	# 	@commentable = klass.find(params["#{klass.name.underscore}_id"])
	# end
end
