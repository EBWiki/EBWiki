# frozen_string_literal: true

# Editor workflow for finding dignified, non-mugshot photos of case subjects.
class FriendlyPhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_case, only: %i[show search classify apply reject]

  def index
    @filter = params[:filter].presence || 'needs_photo'
    @cases = filtered_cases.includes(:subjects, :state, :photo_candidates)
                           .order(updated_at: :desc)
                           .page(params[:page]).per(20)
  end

  def show
    @candidates = @this_case.photo_candidates.ranked
  end

  def search
    @candidates = FriendlyPhotos::CandidateSearch.call(this_case: @this_case)
    flash[:success] = search_flash(@candidates)
    redirect_to friendly_photo_path(@this_case)
  end

  def classify
    kind = params[:avatar_kind].to_s
    unless Case.avatar_kinds.key?(kind)
      flash[:error] = 'Choose a valid photo type.'
      return redirect_to friendly_photo_path(@this_case)
    end

    @this_case.update_column(:avatar_kind, kind) # rubocop:disable Rails/SkipsModelValidations
    flash[:success] = "Marked the current photo as #{kind}."
    redirect_to friendly_photo_path(@this_case)
  end

  def apply
    candidate = @this_case.photo_candidates.find(params[:photo_candidate_id])
    result = FriendlyPhotos::ApplyCandidate.call(
      this_case: @this_case,
      candidate: candidate
    )
    flash[result.success ? :success : :error] =
      result.success ? 'Applied the selected portrait to this case.' : result.error
    redirect_to friendly_photo_path(@this_case)
  end

  def reject
    candidate = @this_case.photo_candidates.find(params[:photo_candidate_id])
    candidate.rejected!
    flash[:success] = 'Rejected that candidate.'
    redirect_to friendly_photo_path(@this_case)
  end

  private

  def set_case
    @this_case = Case.friendly.find(params[:id])
  end

  def filtered_cases
    case @filter
    when 'mugshot' then Case.mugshot
    when 'missing' then Case.where(avatar: [nil, ''])
    when 'unclassified' then Case.unclassified
    when 'portrait' then Case.portrait
    else Case.needing_friendly_photo
    end
  end

  def search_flash(candidates)
    friendly = candidates.count(&:friendly?)
    "Found #{candidates.size} images (#{friendly} not flagged as mugshots)."
  end
end
