# frozen_string_literal: true

# versions controller
class VersionsController < ApplicationController
  # rubocop:disable MethodLength

  def revert
    @case = PaperTrail::Version.find_by_id(params[:id])
    begin
      if @case.reify
        @case.reify.save
      else
        # For undoing the create action
        @case.item.destroy
      end
      flash[:success] = 'Reverted changes' # {make_redo_link}
      flash[:reversion] = @version.next
    rescue StandardError
      flash[:alert] = 'Failed undoing the action...'
      redirect_to :back
    end
  end
  # rubocop:enable MethodLength
end