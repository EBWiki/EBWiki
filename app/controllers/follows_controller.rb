# frozen_string_literal: true

class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    @case = Case.find(params[:case_id])
    current_user.follow(@case)
    redirect_to @case
  end

  def destroy
    @case = Case.find(params[:case_id])
    current_user.stop_following(@case)
    redirect_to @case
  end
end
