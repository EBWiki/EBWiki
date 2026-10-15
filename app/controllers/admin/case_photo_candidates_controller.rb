# frozen_string_literal: true

module Admin
  class CasePhotoCandidatesController < Admin::ApplicationController
    def approve
      candidate = CasePhotoCandidate.find(params[:id])
      CasePhotoCandidatePublisher.new(candidate, reviewer: current_user).approve!
      redirect_to admin_case_photo_candidate_path(candidate),
                  notice: 'Photo approved and attached to the case.'
    rescue CasePhotoCandidatePublisher::Error => e
      redirect_to admin_case_photo_candidate_path(candidate), alert: e.message
    end

    def reject
      candidate = CasePhotoCandidate.find(params[:id])
      CasePhotoCandidatePublisher.new(candidate, reviewer: current_user).reject!(
        reason: params[:rejection_reason]
      )
      redirect_to admin_case_photo_candidates_path, notice: 'Photo candidate rejected.'
    rescue CasePhotoCandidatePublisher::Error => e
      redirect_to admin_case_photo_candidate_path(candidate), alert: e.message
    end
  end
end
