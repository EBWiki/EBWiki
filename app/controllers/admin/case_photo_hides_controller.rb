# frozen_string_literal: true

module Admin
  class CasePhotoHidesController < Admin::ApplicationController
    include CasePhotoRequestsFeature

    def create
      this_case = Case.friendly.find(params[:case_id])
      CasePhotoAdmin::HidePhoto.call(this_case)
      flash[:notice] = 'Case photo hidden.'
      redirect_to this_case
    rescue StandardError
      flash[:alert] = 'Could not hide the case photo.'
      redirect_to request.referer || admin_cases_path
    end
  end
end
