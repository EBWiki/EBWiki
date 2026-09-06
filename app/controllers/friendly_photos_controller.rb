# frozen_string_literal: true

# Editor workflow for finding dignified, non-mugshot photos of case subjects.
class FriendlyPhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_case, only: %i[show search classify apply reject]

  def index
    assign_search_params
    @cases = lookup_cases
             .includes(:subjects, :state, :photo_candidates)
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
  rescue FriendlyPhotos::AiError => e
    flash[:error] = "AI search failed: #{e.message} Check the API key and try again."
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

  def assign_search_params
    @filter = params[:filter].presence || 'needs_photo'
    assign_lookup_fields
  end

  def assign_lookup_fields
    @query = params[:q].to_s.strip
    @location = params[:location].to_s.strip
    @date = params[:date].to_s.strip
    @case_id = params[:case_id].to_s.strip
  end

  def lookup_cases
    FriendlyPhotos::CaseLookup.call(
      filter: @filter,
      query: @query,
      location: @location,
      date: @date,
      case_id: @case_id
    )
  end

  def set_case
    @this_case = Case.friendly.find(params[:id])
  end

  def search_flash(candidates)
    friendly = candidates.count(&:friendly?)
    if candidates.empty?
      'None found: Wikimedia and Openverse returned no openly licensed images.'
    elsif friendly.zero?
      "None found: #{candidates.size} images were mugshots or booking photos " \
        'and cannot be applied.'
    else
      "Found #{candidates.size} images (#{friendly} not flagged as mugshots)."
    end
  end
end
