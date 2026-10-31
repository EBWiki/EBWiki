# frozen_string_literal: true

module Cases
  # versions controller
  class VersionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_case
    before_action :set_version, only: [:revert]

    def revert
      reified = @version.reify
      log_revert_attempt(reified)

      if reified
        complete_revert(reified)
      else
        revert_not_allowed
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
      handle_revert_failure(e)
    end

    private

    def set_case
      @case = Case.friendly.find(params[:case_id])
    end

    def set_version
      @version = @case.versions.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = 'Version not found for this case.'
      redirect_back_or_to @case
    end

    def log_revert_attempt(reified)
      msg = "Revert case=#{@case.id} ver=#{@version.id} reified=#{reified.present?}"
      Rails.logger.debug { msg }
    end

    def complete_revert(reified)
      reified.save!
      Rails.logger.debug { "Reverted case_id=#{@case.id}" }
      flash[:success] = 'Reverted changes'
      flash[:reversion] = @version
      redirect_to @case
    end

    def revert_not_allowed
      flash[:alert] = 'This version cannot be reverted.'
      redirect_back_or_to @case
    end

    def handle_revert_failure(error)
      Rails.logger.debug { "Revert error case_id=#{@case.id}: #{error.message}" }
      Rollbar.error(error)
      flash[:alert] = 'Failed undoing the action...'
      redirect_back_or_to @case
    end
  end
end
