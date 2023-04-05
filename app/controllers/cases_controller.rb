# frozen_string_literal: true

# Cases controller
class CasesController < ApplicationController # rubocop:todo Metrics/ClassLength
  before_action :authenticate_user!, except: %i[index show history followers]
  before_action :set_instance_vars, only: %i[edit new create]

  def new
    @this_case = Case.new
    @this_case.agencies.build
    @this_case.links.build
  end

  def index
    page_size = 12
    @total_cases = Case.count
    @recently_updated_cases = Case.sorted_by_update 10
    @cases = Case.order('date DESC').includes(:state).page(params[:page]).per(page_size)
  end

  # rubocop:disable Metrics/AbcSize
  def show
    eager_load_case = Case.includes(:comments, :subjects, :links)
    @this_case = eager_load_case.order('links.created_at DESC').friendly.find(params[:id])
    @comments = @this_case.comments
    @comment = Comment.new
    @subjects = @this_case.subjects
    @follow_id = current_user.follows.find_by_followable_id(@this_case.id) if user_signed_in?
    # Check to make sure all required elements are here
    unless @this_case.present? # rubocop:todo Style/GuardClause
      flash[:error] = 'There was an error showing this case. Please try again later'
      redirect_to root_path
    end
  end
  # rubocop:enable Metrics/AbcSize

  def create
    @this_case = Case.new(case_params)
    @this_case.blurb = ActionController::Base.helpers.strip_tags(@this_case.blurb)
    # TODO: Create a scope to send only to users who have chosen to receive email updates
    if @this_case.save
      current_user.follow(@this_case)
      flash[:success] = 'Case was created!'
      redirect_to @this_case
    else
      set_instance_vars
      render 'new'
    end
  end

  def edit
    @this_case = Case.friendly.find(params[:id])
    @this_case.links.build
  end

  def followers
    @this_case = Case.friendly.find(params[:case_slug])
  end

  # rubocop:todo Metrics/MethodLength
  def update # rubocop:todo Metrics/AbcSize
    @this_case = Case.find(params[:id])
    @this_case.slug = nil
    @this_case.blurb = ActionController::Base.helpers.strip_tags(@this_case.blurb)
    if @this_case.update(case_params)
      flash[:success] = 'Case was updated!'
      CaseMailer.send_followers_email(users: @this_case.followers,
                                      this_case: @this_case).deliver_now
      redirect_to @this_case
    else
      set_instance_vars
      render 'edit'
    end
  rescue StandardError => e
    Rollbar.error(e)
  end
  # rubocop:enable Metrics/MethodLength

  def destroy
    begin
      @this_case = Case.friendly.find(params[:id])
      @this_case.destroy
      flash[:success] = 'Case was removed!'
      CaseMailer.send_deletion_email(users: @this_case.followers,
                                     this_case: @this_case).deliver_now
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = I18n.t('cases_controller.case_not_found_message')
    end
    redirect_to root_path
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  private

  def case_params # rubocop:todo Metrics/MethodLength
    params[:case][:date] ||= []
    params.require(:case).permit(
      :title,
      :age,
      :overview,
      :litigation,
      :community_action,
      :agency_id,
      :cause_of_death,
      :date,
      :state_id,
      :city,
      :address,
      :zipcode,
      :longitude,
      :latitude,
      :avatar,
      :remove_avatar,
      :video_url,
      :summary,
      :blurb,
      links_attributes: %i[id url title _destroy],
      comments_attributes: %i[comment content commentable_id commentable_type],
      subjects_attributes: %i[name age gender_id ethnicity_id unarmed homeless veteran
                              mentally_ill id _destroy],
      agency_ids: []
    )
  end

  # from the tutorial (https://gorails.com/episodes/comments-with-polymorphic-associations)
  # why did they set commentable here?
  def set_commentable
    @commentable = Case.friendly.find(params[:id])
  end

  def set_instance_vars
    @agencies = SortCollectionOrdinally.call(collection: Agency.all)
    @states = SortCollectionOrdinally.call(collection: State.all)
    @genders = SortCollectionOrdinally.call(collection: Gender.all, column_name: 'sex')
    @ethnicities = SortCollectionOrdinally.call(collection: Ethnicity.all, column_name: 'title')
  end
end
