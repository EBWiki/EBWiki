# frozen_string_literal: true

module Cases
  class PhotoChangeRequestsController < ApplicationController
    include CasePhotoRequestsFeature

    before_action :set_case

    def new
      @photo_change_request = @this_case.case_photo_change_requests.build
    end

    def create
      @photo_change_request = build_photo_change_request
      persist_photo_change_request
    rescue StandardError => e
      report_create_failure(e)
      render :new, status: :unprocessable_content
    end

    private

    def set_case
      @this_case = Case.friendly.find(params[:case_id])
    end

    def build_photo_change_request
      @this_case.case_photo_change_requests.build(photo_change_request_params)
    end

    def persist_photo_change_request
      if @photo_change_request.save
        flash[:success] = 'Your request was received. Thank you.'
        redirect_to @this_case
      else
        flash.now[:error] = 'We could not save your request. Please check the form and try again.'
        render :new, status: :unprocessable_content
      end
    end

    def report_create_failure(error)
      ErrorReporter.report(error, case_id: @this_case.id)
      flash.now[:error] = 'Something went wrong. Please try again later.'
    end

    def photo_change_request_params
      params.require(:case_photo_change_request).permit(
        :request_type,
        :message,
        :requester_contact,
        :replacement_photo
      )
    end
  end
end
