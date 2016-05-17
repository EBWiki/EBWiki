class ArticlesController < ApplicationController
  before_action :find_article, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show, :history, :followers]

  def new
    @article = current_user.articles.build
  end

  def index
    page_size = 12
    @articles = Article.by_state(params[:state_id]).search(params[:query], page: params[:page], per_page: page_size) if params[:query].present? && params[:state_id].present?
    @articles = Article.by_state(params[:state_id]).order('date DESC').page(params[:page]).per(page_size) if !params[:query].present? && params[:state_id].present?
    @articles = Article.search(params[:query], page: params[:page], per_page: page_size) if params[:query].present? && !params[:state_id].present?
    @articles = Article.all.order('date DESC').page(params[:page]).per(page_size) if (!params[:query].present? && !params[:state_id].present?)
  end

  def show
    @article = Article.friendly.find(params[:id])
    @commentable = @article
    @comments = @commentable.comments
    @comment = Comment.new
    @subjects = @article.subjects

    # Check to make sure all required elements are here
    unless @article.present? && @article.present?	&& @commentable.present? && @comment.present? &&
        @subjects.present?
      flash[:error] = "There was an error showing this case. Please try again later"
      redirect_to	root_path
    end
  end

  def create
    @article = current_user.articles.build(article_params)
    # This could be a very expensive query as the userbase gets larger.
    # TODO: Create a scope to send only to users who have chosen to receive email updates
    if @article.save
      flash[:success] = "Article was created! #{make_undo_link}"
      redirect_to @article
    else
      render 'new'
    end
  end

  def edit
    @article = Article.friendly.find(params[:id])
    @article.update_attribute(:summary, nil)
  end

  def followers
    @article = Article.friendly.find(params[:id])
  end

  def update
    @article = Article.friendly.find(params[:id])
    @article.slug = nil
    if @article.remove_avatar?
      @article.remove_avatar!
    end
    if @article.update_attributes(article_params)
      flash[:success] = "Article was updated! #{make_undo_link}"
      UserNotifier.send_followers_email(@article.followers,@article).deliver_now
      redirect_to @article
    else
      render 'edit'
    end
  end

  def destroy
    @article.destroy
    flash[:success] = "Article was removed! #{make_undo_link}"
    UserNotifier.notify_of_removal(@article.followers,@article).deliver_now
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
    params.require(:article).permit(:title, :age, :overview, :litigation, :community_action, :agency_id, :category_id, :date, :state_id, :city, :address, :zipcode, :longitude, :latitude, :avatar, :video_url, :remove_avatar, :summary, links_attributes: [:id, :url, :_destroy],  comments_attributes: [:comment, :content, :commentable_id, :commentable_type], subjects_attributes: [:name, :age, :gender_id, :ethnicity_id, :unarmed, :homeless, :veteran, :mentally_ill, :id, :_destroy])
  end

  # from the tutorial (https://gorails.com/episodes/comments-with-polymorphic-associations)
  # why did they set commentable here?
  def set_commentable
    @commentable = Article.friendly.find(params[:id])
  end
end
