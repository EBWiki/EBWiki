class VersionsController < ApplicationController

  def revert
    @version = PaperTrail::Version.find(params[:id])
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end
    link_name = params[:redo] == "true" ? "Undo please!" : "Redo please!"
    link = view_context.link_to(link_name, versions_revert_path(@version.next, redo: !params[:redo]), method: :post)
    redirect_to :back, notice: "Undid #{@version.event}. #{link}"
  end
end
