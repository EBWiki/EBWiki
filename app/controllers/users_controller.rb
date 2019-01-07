# frozen_string_literal: true

# EBWiki Users controller
class UsersController < ApplicationController
  before_action :find_user, only: [:show, :edit,:update,:update_email]
  
  def show   
  end

  def edit
  end

  def update
    authorize @user
    if @user.update_attributes(user_params)
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
    authorize @user
    if @user.update_attributes(email_params)
      flash[:success] = 'Your email was updated!'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :description, :subscribed)
  end

  def find_user
    @user = User.find(params[:id])
    redirect_to users_path unless @user.present?
  end
  def email_params
    params.require(:user).permit(:email)
  end
  
   def mailbox
    @mailbox ||= current_user.mailbox
  end
end
