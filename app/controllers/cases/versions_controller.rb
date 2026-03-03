# frozen_string_literal: true

module Cases
  # versions controller
  class VersionsController < ApplicationController
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize

    def revert
      @case = Case.friendly.find(revert_params[:case_id])
      version = PaperTrail::Version.find_by(id: revert_params[:id])
      msg = "Revert case=#{@case.id} ver=#{version&.id} reified=#{version&.reify.present?}"
      Rails.logger.debug { msg }

      begin
        if version&.reify
          @case.paper_trail.previous_version
          @case.save
          Rails.logger.debug { "Reverted case_id=#{@case.id}" }
          flash[:success] = 'Reverted changes' # {make_redo_link}
          flash[:reversion] = version
          redirect_to @case
        else
          # For undoing the create action
          @case.item.destroy
          Rails.logger.debug { "Destroyed case_id=#{@case.id}" }
          flash[:success] = 'Case deleted'
          redirect_to root_path
        end
      rescue StandardError => e
        Rails.logger.debug { "Revert error case_id=#{@case.id}: #{e.message}" }
        flash[:alert] = 'Failed undoing the action...'
        redirect_back(fallback_location: @case)
      end
    end

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    def save_my_previous_url
      # session[:previous_url] is a Rails built-in variable to save last url.
      referer_path = begin
        request.referer.present? ? URI.parse(request.referer).path : nil
      rescue URI::InvalidURIError
        nil
      end
      Rails.logger.debug { "redirect_path=#{referer_path}" }
      session[:previous_url] = referer_path
    end

    def revert_params
      params.permit(:case_id, :id)
    end
  end
end
