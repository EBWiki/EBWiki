# frozen_string_literal: true

# Versions Controller
class VersionsController < ApplicationController
  # Undoing
  def revert
    @version = PaperTrail::Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    redirect_to :back, notice: "Undid #{@version.event}. #{link}"
  end

  private

  # link to undo/redo
  def link
    begin
      link_name = params[:redo] == 'true' ? 'Undo please!' : 'Redo please!'
      view_context.link_to(
        link_name, versions_revert_path(@version.next, redo: !params[:redo]), method: :post
      )  
    rescue Exception
      flash[:notice] = 'Error'
    end
  end
end
