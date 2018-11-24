# frozen_string_literal: true

# Handles user registration
class Users::RegistrationsController < Devise::RegistrationsController
  # POST /resource
  def create
    if gotcha_valid?
      super
      OnboardUser.call(resource)
    else
      clean_up_passwords resource
      @minimum_password_length = resource_class.password_length.min if devise_mapping.validatable?
      flash[:notice] = 'Invalid Captcha'
      redirect_to '/users/sign_up'
    end
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    user_path(resource)
  end
end
