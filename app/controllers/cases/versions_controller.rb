# frozen_string_literal: true

module Cases
  # versions controller
  class VersionsController < ApplicationController
    # rubocop:disable Metrics/MethodLength

    def revert
      @case = Case.friendly.find(revert_params[:case_id])
      version = PaperTrail::Version.find_by_id(revert_params[:id])
      begin
        if version.reify
          @case.paper_trail.previous_version
          @case.save
        else
          # For undoing the create action
          @case.item.destroy
        end
        redirect_to @case
        flash[:success] = 'Reverted changes' # {make_redo_link}
        flash[:reversion] = version
      rescue StandardError
        flash[:alert] = 'Failed undoing the action...'
        redirect_to :back
      end
    end

    # rubocop:enable Metrics/MethodLength

    private

    def save_my_previous_url
      # session[:previous_url] is a Rails built-in variable to save last url.
      session[:previous_url] = URI(request.referer || '').path
    end

    def revert_params
      params.permit(:case_id, :id)
    end
  end
end
