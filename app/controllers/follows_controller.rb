# frozen_string_literal: true

# Controller for the follows associated model
class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    @case = Case.friendly.find(params[:case_slug])
    current_user.follow(@case)
    redirect_to @case
  end

  def destroy
    @case = Case.friendly.find(params[:case_slug])
    current_user.stop_following(@case)
    redirect_to @case
  end
end
