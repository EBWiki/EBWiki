# frozen_string_literal: true

# EBWiki Users controller
class UsersController < ApplicationController
  around_action :skip_bullet, only: :show

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
    if @user.update_attributes(user_params)
      SendAdminEmail.call(user: @user) if @user.previous_changes.include?('admin')
      flash[:success] = 'Your profile was updated!'
      redirect_to @user
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
    if @user.update_attributes(user_param)
      flash[:success] = 'Email updated Successfully!'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    if current_user.admin?
      params.require(:user).permit(:admin)
    else
      params.require(:user).permit(:name, :email, :description, :subscribed)
    end
  end

  def user_param
    params.require(:user).permit(:email)
  end

  def mailbox
    @mailbox ||= current_user.mailbox
  end

  def skip_bullet
    previous_value = Bullet.enable?
    Bullet.enable = false
    yield
  ensure
    Bullet.enable = previous_value
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to @user
  end
end
