# frozen_string_literal: true

# Handles User registration
class Users::RegistrationsController < Devise::RegistrationsController
  # POST /resource
  def create
    if User.where(email: params[:user][:email]).any?
      flash[:warning] = %Q{
        Looks like that email is already taken you can login
        here or <a href=#{new_user_registration_path}>go back to sign up</a>
      }.html_safe
      redirect_to new_user_session_path(user: { email: params[:user][:email] }) and return
    end

    super

    OnboardUser.call(resource)
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    user_path(resource)
  end
end
