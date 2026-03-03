# frozen_string_literal: true

module Cases
  # versions controller
  class VersionsController < ApplicationController
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize

    def revert
      @case = Case.friendly.find(revert_params[:case_id])
      version = PaperTrail::Version.find_by(id: revert_params[:id])
      Rails.logger.debug { "Case: #{@case.inspect}" }
      Rails.logger.debug { "Version: #{version.inspect}" }
      Rails.logger.debug { "Version reify: #{version&.reify.inspect}" }

      begin
        if version&.reify
          @case.paper_trail.previous_version
          @case.save
          Rails.logger.debug 'Successfully reverted to previous version'
          flash[:success] = 'Reverted changes' # {make_redo_link}
          flash[:reversion] = version
          Rails.logger.debug { "Redirecting to case: #{@case}" }
          redirect_to @case
        else
          # For undoing the create action
          @case.item.destroy
          Rails.logger.debug 'Destroyed case item'
          flash[:success] = 'Case deleted'
          redirect_to root_path
        end
      rescue StandardError => e
        Rails.logger.debug { "Error during revert: #{e.message}" }
        Rails.logger.debug e.backtrace.first(5)
        flash[:alert] = 'Failed undoing the action...'
        redirect_back(fallback_location: @case)
      end
    end

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    def save_my_previous_url
      # session[:previous_url] is a Rails built-in variable to save last url.
      Rails.logger.debug { "request.referer: #{request.referer}" }
      session[:previous_url] = URI(request.referer || '').path
    end

    def revert_params
      params.permit(:case_id, :id)
    end
  end
end
