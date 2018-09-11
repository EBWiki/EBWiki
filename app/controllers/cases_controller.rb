# frozen_string_literal: true

# Cases controller. Containing really complex index method that needs some
# Refactoring love.
class CasesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show history followers]

  def new
    @this_case = current_user.cases.build
    @this_case.agencies.build
    @this_case.links.build
    @agencies = SortCollectionOrdinally.call(Agency.all)
    @categories = SortCollectionOrdinally.call(Category.all)
    @states = SortCollectionOrdinally.call(State.all)
    @genders = SortCollectionOrdinally.call(Gender.all)
  end

  def index
    page_size = 12
    @recently_updated_cases = Case.sorted_by_update 10
    @cases = Case.includes(:state).by_state(params[:state_id]).search(params[:query], page: params[:page], per_page: page_size) if params[:query].present? && params[:state_id].present?
    @cases = Case.includes(:state).by_state(params[:state_id]).order('date DESC').page(params[:page]).per(page_size) if !params[:query].present? && params[:state_id].present?
    @cases = Case.search(params[:query], fields: ['*'], page: params[:page], per_page: page_size) if params[:query].present? && !params[:state_id].present?
    @cases = Case.all.order('date DESC').includes(:state).page(params[:page]).per(page_size) if !params[:query].present? && !params[:state_id].present?
  end

  def show
    @this_case = Case.friendly.find(params[:id])
    @comments = @this_case.comments
    @comment = Comment.new
    @subjects = @this_case.subjects
    # Check to make sure all required elements are here
    unless @this_case.present? && @comment.present? && @subjects.present?
      flash[:error] = 'There was an error showing this case. Please try again later'
      redirect_to root_path
    end  
      # If an old id or a numeric id was used to find the record, then
      # the request path will not match the case_path, and we should do
      # a 301 redirect that uses the current friendly id.
    return redirect_to @this_case, status: :moved_permanent if request.path != case_path(@this_case)
     
  end

  def create
    @this_case = current_user.cases.build(case_params)
    @this_case.blurb = ActionController::Base.helpers.strip_tags(@this_case.blurb)
    # This could be a very expensive query as the userbase gets larger.
    # TODO: Create a scope to send only to users who have chosen to receive email updates
    if @this_case.save
      flash[:success] = 'Case was created!' # {make_undo_link}
      redirect_to @this_case
    else
      @agencies = SortCollectionOrdinally.call(Agency.all)
      @categories = SortCollectionOrdinally.call(Category.all)
      @states = SortCollectionOrdinally.call(State.all)
      render 'new'
    end
  end

  def edit
    @this_case = Case.friendly.find(params[:id])
    @this_case.update_attribute(:summary, nil)
    @this_case.links.build
    @agencies = SortCollectionOrdinally.call(Agency.all)
    @categories = SortCollectionOrdinally.call(Category.all)
    @states = SortCollectionOrdinally.call(State.all)
    @genders = SortCollectionOrdinally.call(Gender.all)
  end

  def followers
    @this_case = Case.friendly.find(params[:id])
  end

  def update
    @this_case = Case.friendly.find(params[:id])
    # @this_case.slug = nil
    @this_case.remove_avatar! if @this_case.remove_avatar?
    @this_case.blurb = ActionController::Base.helpers.strip_tags(@this_case.blurb)
    if @this_case.update_attributes(case_params)
      flash[:success] = 'Case was updated!' # {make_undo_link}
      UserNotifier.send_followers_email(@this_case.followers, @this_case).deliver_now
      redirect_to @this_case
    else
      @categories = SortCollectionOrdinally.call(Category.all)
      @states = SortCollectionOrdinally.call(State.all)
      render 'edit'
    end
  end

  def destroy
    begin
      @this_case = Case.friendly.find(params[:id])
      @this_case.destroy
      flash[:success] = 'Case was removed!' # {make_undo_link}
      UserNotifier.send_deletion_email(@this_case.followers, @this_case).deliver_now
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = I18n.t('cases_controller.case_not_found_message')
    end
    redirect_to root_path
  end

  def history
    @this_case = Case.friendly.find(params[:id])
    @case_history = @this_case.try(:versions).order(created_at: :desc) unless
    @this_case.blank? || @this_case.versions.blank?
  rescue ActiveRecord::RecordNotFound
  end

  def undo
    @case_version = PaperTrail::Version.find(params[:id])
    begin
      if @case_version.reify
        @case_version.reify.save
      else
        # For undoing the create action
        @case_version.item.destroy
      end
      flash[:success] = 'Undid that!' # {make_redo_link}
    rescue
      flash[:alert] = 'Failed undoing the action...'
    ensure
      redirect_to root_path
    end
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end

  private

  def case_params
    params.require(:case).permit(
                                  :title,
                                  :age,
                                  :overview,
                                  :litigation,
                                  :community_action,
                                  :agency_id,
                                  :category_id,
                                  :date,
                                  :state_id,
                                  :city,
                                  :address,
                                  :zipcode,
                                  :longitude,
                                  :latitude,
                                  :avatar,
                                  :video_url,
                                  :remove_avatar,
                                  :summary,
                                  :blurb,
                                  links_attributes: %i[id url title _destroy],
                                  comments_attributes: \
                                    I18n.t('cases_controller.comments_attributes').map(&:to_sym),
                                  subjects_attributes: \
                                    I18n.t('cases_controller.subjects_attributes').map(&:to_sym),
                                  agency_ids: []
                                )
  end

  # from the tutorial (https://gorails.com/episodes/comments-with-polymorphic-associations)
  # why did they set commentable here?
  def set_commentable
    @commentable = Case.friendly.find(params[:id])
  end
end
