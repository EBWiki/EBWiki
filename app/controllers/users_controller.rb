# frozen_string_literal: true

# EBWiki Users controller
class UsersController < ApplicationController
  # Temporarily commented out for Rails 8.1 compatibility
  # around_action :skip_bullet, only: :show

  def show
    @user = User.find(params[:id])
    @cases = @user.all_following
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update(user_params)
      SendAdminEmail.call(user: @user) if @user.previous_changes.include?('admin')
      flash[:success] = 'Your profile was updated!'
      redirect_to user_path(@user)
    else
      render 'edit'
    end
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end

  def update_email
    @user = User.find(params[:id])
    authorize @user
    if @user.update(user_param)
      flash[:success] = 'Email updated Successfully!'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    if current_user.admin?
      params.expect(user: [:admin])
    else
      params.expect(user: %i[name email description subscribed])
    end
  end

  def user_param
    params.expect(user: [:email])
  end

  def mailbox
    @mailbox ||= current_user.mailbox
  end

  # Temporarily commented out for Rails 8.1 compatibility
  # def skip_bullet
  #   previous_value = Bullet.enable?
  #   Bullet.enable = false
  #   yield
  # ensure
  #   Bullet.enable = previous_value
  # end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to @user
  end
end
