# frozen_string_literal: true

module Admin
  class CasePhotoHidesController < Admin::ApplicationController
    include CasePhotoRequestsFeature

    before_action :assign_paper_trail_whodunnit

    def create
      this_case = Case.friendly.find(params[:case_id])
      result = hide_case_photo(this_case)
      flash[:notice] = flash_message_for(result)
      redirect_to this_case
    rescue StandardError
      flash[:alert] = 'Could not hide the case photo.'
      redirect_to request.referer || admin_cases_path
    end

    private

    def hide_case_photo(this_case)
      PaperTrail.request(whodunnit: paper_trail_whodunnit) do
        CasePhotoAdmin::HidePhoto.call(this_case)
      end
    end

    def assign_paper_trail_whodunnit
      PaperTrail.request.whodunnit = current_user.id.to_s if current_user
    end

    def paper_trail_whodunnit
      current_user&.id&.to_s
    end

    def flash_message_for(result)
      case result.reason
      when CasePhotoAdmin::HidePhoto::SKIPPED_ALREADY_HIDDEN
        'Case photo was already hidden.'
      when CasePhotoAdmin::HidePhoto::SKIPPED_ALREADY_REMOVED
        'Case photo is marked removed; nothing was changed.'
      when CasePhotoAdmin::HidePhoto::SKIPPED_NOT_SHOWN
        'Case photo is not currently shown; nothing was changed.'
      else
        'Case photo hidden.'
      end
    end
  end
end
